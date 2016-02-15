class Mother
  OKAY = ['200', { 'content-Type' => 'text/html' }, ['OKAY']].freeze
  INVALID = ['400', { 'content-Type' => 'text/html' }, ['INVALID']].freeze

  attr_reader :rack_request

  def call(env)
    @rack_request = Rack::Request.new(env)
    return OKAY if params.to_h.empty?
    reading = Reading.create(params)
    return INVALID unless reading.valid?
    generate_data_files
    OKAY
  end

  private

  def generate_data_files
    file_pointer = File.open("#{config['csv_folder']}/temperatures.csv", 'w')
    DataFileGenerator.new(file_pointer).call
  ensure
    file_pointer.try(:close)
  end

  def config
    YAML.load_file(File.expand_path('../../config/hivemom.yml', __FILE__))
  end

  def params
    rack_request.params.with_indifferent_access
  end
end
