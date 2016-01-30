require 'rack'

class Mother
  attr_reader :request

  def call(env)
    @request = Rack::Request.new(env)
    puts "Received Request: #{request.inspect}"
    puts "Params: #{params}"
    ['200', {'content-Type' => 'text/html'}, ['OKAY']]
  end

  private

  def params
    @params ||= request.params
  end
end

Rack::Server.start(app: Mother.new, host: '0.0.0.0')
