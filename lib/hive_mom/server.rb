module HiveMom
  class Server
    OKAY = ['200', { 'content-Type' => 'text/html' }, ['OKAY']].freeze
    INVALID = ['400', { 'content-Type' => 'text/html' }, ['INVALID']].freeze

    attr_reader :rack_request, :s3_resourcer

    def initialize(s3_resourcer = Aws::S3::Resource)
      @s3_resourcer = s3_resourcer
    end

    def call(env)
      @rack_request = Rack::Request.new(env)
      log_request
      return OKAY if params.to_h.empty?
      reading = Reading.create(params)
      return INVALID unless reading.valid?
      generate_and_upload_data_files
      OKAY
    end

    private

    def log_request
      req = rack_request
      msg = "Received: #{req.request_method} from #{req.ip}, "\
            "Length: #{req.content_length}"
      HiveMom.logger.info(self.class) { msg }
    end

    def generate_and_upload_data_files
      [:minutely, :hourly, :daily].each do |span|
        generate_data_file(span)
        upload_data_file(span)
      end
    end

    def generate_data_file(span)
      file_pointer = File.open("#{csv_folder}/#{filename_for(span)}", 'w')
      readings = ReadingComposition.new(span).composite_readings
      DataFileGenerator.new(file_pointer, readings).call
    ensure
      file_pointer.try(:close)
    end

    def upload_data_file(span)
      puts HiveMom.config.aws_region
      s3 = @s3_resourcer.new(region: HiveMom.config.aws_region)
      obj = s3.bucket("hivemom-datafiles-#{HiveMom.config.env}")
              .object(filename_for(span))
      obj.upload_file("#{csv_folder}/#{filename_for(span)}")
    end

    def filename_for(span)
      "#{span}_data.csv"
    end

    def csv_folder
      HiveMom.config.csv_folder
    end

    def params
      rack_request.params.with_indifferent_access
    end
  end
end
