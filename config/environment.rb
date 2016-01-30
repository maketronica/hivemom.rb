require 'rack'
require 'yaml'
require 'logger'
require 'active_record'
Dir.glob('./lib/**/*.rb').each { |file| require file }

db_config = YAML.load_file('config/database.yml')['hivemom']
ActiveRecord::Base.establish_connection(db_config)
