require 'bundler/setup'
require 'csv'
require 'rack'
require 'yaml'
require 'logger'
require 'active_record'
Dir.glob('./lib/**/*.rb').each { |file| require file }

env = ENV['HIVEMOM_ENV'] || 'development'
db_config = YAML.load_file('config/database.yml')[env]
ActiveRecord::Base.establish_connection(db_config)
