require 'bundler/setup'
require 'csv'
require 'rack'
require 'remote_syslog_logger'
require 'yaml'
require 'logger'
require 'active_record'
require 'aws-sdk'

Dir.glob(File.expand_path('../../lib/**/*.rb', __FILE__))
   .each { |file| require file }

HiveMom.config.env = ENV['HIVEMOM_ENV'] || 'development'
require_relative '../config/hivemom.rb' unless HiveMom.config.env == 'test'

db_file = File.expand_path('../database.yml', __FILE__)
db_config = YAML.load_file(db_file)[HiveMom.config.env]
ActiveRecord::Base.establish_connection(db_config)

Aws.config.update(
  region: HiveMom.config.aws_region,
  credentials: Aws::Credentials.new(
    HiveMom.config.aws_key_id,
    HiveMom.config.aws_secret)
)
