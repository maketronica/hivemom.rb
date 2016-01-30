class Mother
  OKAY = ['200', {'content-Type' => 'text/html'}, ['OKAY']]
  INVALID = ['400', {'content-Type' => 'text/html'}, ['INVALID']]

  attr_reader :request

  def call(env)
    @request = Rack::Request.new(env)
    return OKAY if params[:reading].to_h.empty?
    reading = Reading.create(params[:reading])
    reading.valid? ? OKAY : INVALID
  end

  private

  def params
    request.params.with_indifferent_access
  end
end
