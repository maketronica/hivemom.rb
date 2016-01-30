require_relative 'config/environment.rb'

class Mother
  attr_reader :request

  def call(env)
    @request = Rack::Request.new(env)
    return if params.empty?
    puts "Received Request: #{request.inspect}"
    puts "Params: #{params}"
    reading = Reading.create(params)
    reading.valid?
    puts reading.inspect
    puts reading.errors.inspect
    ['200', {'content-Type' => 'text/html'}, ['OKAY']]
  end

  private

  def params
    request.params
  end
end

Rack::Server.start(app: Mother.new, host: '0.0.0.0')
