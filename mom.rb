require_relative 'config/environment.rb'
Rack::Server.start(app: Mother.new, host: '0.0.0.0')
