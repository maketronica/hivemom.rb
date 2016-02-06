class Mother
  OKAY = ['200', { 'content-Type' => 'text/html' }, ['OKAY']].freeze
  INVALID = ['400', { 'content-Type' => 'text/html' }, ['INVALID']].freeze

  attr_reader :request

  def call(env)
    @request = Rack::Request.new(env)
puts @request.inspect
puts params.inspect
    return OKAY if params.to_h.empty?
    reading = Reading.create(params)
puts reading.inspect
    reading.valid? ? OKAY : INVALID
  end

  private

  def params
    request.params.with_indifferent_access
  end
end
