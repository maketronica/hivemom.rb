module HiveMom
  class ReadingCompositor
    attr_reader :s3_resourcer, :csv_compiler

    def initialize(s3_resourcer = Aws::S3::Resource,
                   csv_compiler = CsvCompilation)
      @s3_resourcer = s3_resourcer
      @csv_compiler = csv_compiler
    end

    def run
      loop do
        compositions.each do |composition|
          composition.update
          composition.generate_data_file
          composition.upload_data_file
        end
        HiveMom.logger.info(self.class) { 'Hybernating' }
        sleep 900
      end
    end

    def compositions
      @compositions ||= %w(instant hour day).map do |name|
        Composition.new(name, self)
      end
    end

    class Composition
      attr_reader :name, :compositor

      def initialize(name, compositor)
        @name = name
        @compositor = compositor
      end

      def update
        return if name.to_sym == :instant
        Reading.pluck(:hive_id).uniq.each do |hive_id|
          @rescue_wait_time = 1.1
          begin
            update_latest_composite(hive_id)
            create_new_composite(hive_id)
          rescue ActiveRecord::StatementInvalid => e
            process_rescued_error(e)
          end
        end
      end

      def generate_data_file
        file_pointer = File.open("#{csv_folder}/#{filename}", 'w')
        file_pointer.write(csv_compilation.content)
      ensure
        file_pointer.try(:close)
      end

      # rubocop:disable Metrics/AbcSize
      def upload_data_file
        s3 = compositor.s3_resourcer.new(region: HiveMom.config.aws_region)
        obj = s3.bucket("hivemom-datafiles-#{HiveMom.config.env}")
                .object(filename)
        obj.put(csv_compilation.content)
      rescue Errno::ECONNRESET
        HiveMom.logger.info(self.class) do
          "Rescuing from connection reset on uplodad: #{filename}"\
          'Will try again later.'
        end
      end
      # rubocop:enable Metrics/AbcSize

      private

      # rubocop:disable Style/MethodLength, Metrics/AbcSize
      def update_latest_composite(hive_id)
        length = 1.send(name)
        hive_composite = latest(hive_id)
        readings = Reading.where(hive_id: hive_id)
                          .where(['sampled_at >= ? AND sampled_at < ?',
                                  hive_composite.sampled_at,
                                  hive_composite.sampled_at + length])
        composited_columns =
          Reading.column_names - Reading::UNCOMPOSITED_COLUMNS
        params = composited_columns.map do |column_name|
          [column_name, readings.average(column_name).to_i]
        end.to_h
        hive_composite.update!(params)
      end
      # rubocop:enable Style/MethodLength, Metrics/AbcSize

      def latest(hive_id)
        Reading.composite(name).for_hive(hive_id)
               .order(:sampled_at).last ||
          create_new_composite(hive_id)
      end

      # rubocop:disable Style/MethodLength, Metrics/AbcSize
      def create_new_composite(hive_id)
        sampled_at = nil
        if Reading.composite(name).for_hive(hive_id).any?
          length = 1.send(name)
          last_composite = Reading.composite(name)
                                  .for_hive(hive_id).last
          if Reading.instant
                    .where(['sampled_at > ?',
                            last_composite.sampled_at + length]).any?
            reading = Reading.instant
                             .where(['sampled_at > ?',
                                     last_composite.sampled_at + length])
                             .order(:sampled_at).first
            sampled_at = reading.sampled_at.send("beginning_of_#{name}")
          else
            return
          end
        else
          reading = Reading.instant.order(:sampled_at).first
          sampled_at = reading.sampled_at.send("beginning_of_#{name}")
        end
        Reading.composite(name)
               .create(hive_id: hive_id,
                       composite: name,
                       sampled_at: sampled_at)
      end
      # rubocop:enable Style/MethodLength, Metrics/AbcSize

      def process_rescued_error(e)
        raise e unless e.message =~ /SQLite3::BusyException/
        HiveMom.logger.error(self.class) do
          "Compositor Rescuing from #{e.class} : #{e.message}\n"\
          "Compositor Waiting for #{@rescue_wait_time} seconds."
        end
        sleep @rescue_wait_time
        @rescue_wait_time **= 2
      end

      def csv_folder
        HiveMom.config.csv_folder
      end

      def filename
        "#{name}_data.csv"
      end

      def csv_compilation
        @compiliation ||= compositor.csv_compiler.new(name)
      end
    end
  end
end
