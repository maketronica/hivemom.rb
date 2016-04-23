module HiveMom
  class ReadingCompositor
    attr_reader :csv_writer, :s3_resourcer

    def initialize(s3_resourcer = Aws::S3::Resource,
                   csv_writer = Csv)
      @s3_resourcer = s3_resourcer
      @csv_writer = csv_writer
    end

    def run
      loop do
        composition_sets.each(&:update)
        csvs.each do |csv|
          csv.write_to_file
          csv.upload
        end
        HiveMom.logger.info(self.class) { 'Hybernating' }
        sleep 900
      end
    end

    def s3_bucket
      @bucket ||= s3_resource.bucket("hivemom-datafiles-#{HiveMom.config.env}")
    end

    private

    def composition_sets
      @composition_sets ||= %w(instant hour day).map do |name|
        CompositionSet.new(name, self)
      end
    end

    def csvs
      %w(instant hour day).map do |name|
        csv_writer.new(name, self)
      end
    end

    def s3_resource
      @s3_resource ||= s3_resourcer.new(region: HiveMom.config.aws_region)
    end
  end
end
