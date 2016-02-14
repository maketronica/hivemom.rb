require 'bundler/setup'
require 'csv'
require 'rack'
require 'yaml'
require 'logger'
require 'active_record'
Dir.glob(File.expand_path('../../lib/**/*.rb', __FILE__))
   .each { |file| require file }

env = ENV['HIVEMOM_ENV'] || 'development'
db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))[env]
ActiveRecord::Base.establish_connection(db_config)
