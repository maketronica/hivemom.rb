require_relative 'config/environment.rb'
Rack::Server.start(app: Mother.new, Host: '192.168.2.1')
