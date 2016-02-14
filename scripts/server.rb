ENV['HIVEMOM_ENV'] = 'production'
require_relative '../config/environment.rb'
Dir.chdir File.expand_path('../..', __FILE__)
Rack::Server.start(app: Mother.new, Host: '192.168.2.1')
