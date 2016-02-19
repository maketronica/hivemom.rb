class Mother
  OKAY = ['200', { 'content-Type' => 'text/html' }, ['OKAY']].freeze
  INVALID = ['400', { 'content-Type' => 'text/html' }, ['INVALID']].freeze

  attr_reader :rack_request

  def call(env)
    @rack_request = Rack::Request.new(env)
    log_request
    return OKAY if params.to_h.empty?
    reading = Reading.create(params)
    return INVALID unless reading.valid?
    generate_data_files
    OKAY
  end

  private

  def log_request
    req = rack_request
    msg = "Received: #{req.request_method} from #{req.ip}, "\
          "Length: #{req.content_length}"
    HiveMom.logger.info(self.class) { msg }
  end

  def generate_data_files
    DataFileGenerator.new(file_pointer).call
  ensure
    file_pointer.try(:close)
  end

  def file_pointer
    @file_pointer ||= File.open("#{csv_folder}/temperatures.csv", 'w')
  end

  def csv_folder
    HiveMom.config.csv_folder
  end

  def params
    rack_request.params.with_indifferent_access
  end
end
