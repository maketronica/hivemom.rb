# rubocop:disable Style/ClassLength
module HiveMom
  class ReadingCompositor
    attr_reader :s3_resourcer

    def initialize(s3_resourcer = Aws::S3::Resource)
      @s3_resourcer = s3_resourcer
    end

    def run
      loop do
        %w(hour day).each { |name| update_composites(name) }
        generate_and_upload_data_files
        HiveMom.logger.info(self.class) { 'Hybernating' }
        sleep 900
      end
    end

    private

    def update_composites(composite_name)
      Reading.pluck(:hive_id).uniq.each do |hive_id|
        @rescue_wait_time = 1.1
        begin
          update_latest_composite(composite_name, hive_id)
          create_new_composite(composite_name, hive_id)
        rescue ActiveRecord::StatementInvalid => e
          process_rescued_error(e)
        end
      end
    end

    def generate_and_upload_data_files
      %w(instant hour day).each do |composite|
        HiveMom.logger.info(self.class) do
          "Generating Data File: #{filename_for(composite)}"
        end
        generate_data_file(composite)
        upload_data_file(composite)
      end
    end

    def generate_data_file(composite)
      file_pointer = File.open("#{csv_folder}/#{filename_for(composite)}", 'w')
      DataFileGenerator.new(file_pointer, composite).call
    ensure
      file_pointer.try(:close)
    end

    def upload_data_file(composite)
      s3 = s3_resourcer.new(region: HiveMom.config.aws_region)
      obj = s3.bucket("hivemom-datafiles-#{HiveMom.config.env}")
              .object(filename_for(composite))
      obj.upload_file("#{csv_folder}/#{filename_for(composite)}")
    end

    def csv_folder
      HiveMom.config.csv_folder
    end

    def filename_for(composite)
      "#{composite}_data.csv"
    end

    # rubocop:disable Style/MethodLength
    def update_latest_composite(composite_name, hive_id)
      length = 1.send(composite_name)
      composite = latest_composite(composite_name, hive_id)
      readings = Reading.where(hive_id: hive_id)
                        .where(['sampled_at >= ? AND sampled_at < ?',
                                composite.sampled_at,
                                composite.sampled_at + length])
      composited_columns = Reading.column_names - Reading::UNCOMPOSITED_COLUMNS
      params = composited_columns.map do |column_name|
        [column_name, readings.average(column_name).to_i]
      end.to_h
      composite.update!(params)
    end
    # rubocop:enable Style/MethodLength

    def latest_composite(composite_name, hive_id)
      Reading.composite(composite_name).for_hive(hive_id)
             .order(:sampled_at).last ||
        create_new_composite(composite_name, hive_id)
    end

    # rubocop:disable Style/MethodLength, Metrics/AbcSize
    def create_new_composite(composite_name, hive_id)
      sampled_at = nil
      if Reading.composite(composite_name).for_hive(hive_id).any?
        length = 1.send(composite_name)
        last_composite = Reading.composite(composite_name)
                                .for_hive(hive_id).last
        if Reading.instant
                  .where(['sampled_at > ?',
                          last_composite.sampled_at + length]).any?
          reading = Reading.instant
                           .where(['sampled_at > ?',
                                   last_composite.sampled_at + length])
                           .order(:sampled_at).first
          sampled_at = reading.sampled_at.send("beginning_of_#{composite_name}")
        else
          return
        end
      else
        reading = Reading.instant.order(:sampled_at).first
        sampled_at = reading.sampled_at.send("beginning_of_#{composite_name}")
      end
      Reading.composite(composite_name)
             .create(hive_id: hive_id,
                     composite: composite_name,
                     sampled_at: sampled_at)
    end
    # rubocop:enable Style/MethodLength, Metrics/AbcSize

    def process_rescued_error(e)
      raise e unless e.messageo =~ /SQLite3::BusyException/
      HiveMom.logger.error(self.class) do
        "Compositor Rescuing from #{e.class} : #{e.message}\n"\
        "Compositor Waiting for #{@rescue_wait_time} seconds."
      end
      sleep @rescue_wait_time
      @rescue_wait_time **= 2
    end
  end
end
# rubocop:enable Style/ClassLength
