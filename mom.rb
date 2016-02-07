require_relative 'config/environment.rb'
Rack::Server.start(app: Mother.new, Host: 'localhost')
