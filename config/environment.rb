require 'bundler/setup'
require 'csv'
require 'rack'
require 'yaml'
require 'logger'
require 'active_record'

env = ENV['HIVEMOM_ENV'] || 'development'

Dir.glob(File.expand_path('../../lib/**/*.rb', __FILE__))
   .each { |file| require file }
require_relative '../config/hivemom.rb' unless env == 'test'

db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))[env]
ActiveRecord::Base.establish_connection(db_config)
