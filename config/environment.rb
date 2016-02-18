require 'bundler/setup'
require 'csv'
require 'rack'
require 'yaml'
require 'logger'
require 'active_record'

Dir.glob(File.expand_path('../../lib/**/*.rb', __FILE__))
   .each { |file| require file }

HiveMom.config.env = ENV['HIVEMOM_ENV'] || 'development'
require_relative '../config/hivemom.rb' unless HiveMom.config.env == 'test'

db_file = File.expand_path('../database.yml', __FILE__)
db_config = YAML.load_file(db_file)[HiveMom.config.env]
ActiveRecord::Base.establish_connection(db_config)
