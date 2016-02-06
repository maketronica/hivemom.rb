# frozen_string_literal: true
require_relative 'config/environment.rb'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: [:rubocop, :spec]

task :rubocop do
  RuboCop::RakeTask.new
end

task :spec do
  RSpec::Core::RakeTask.new(:spec)
end

namespace :db do
  task :environment do
    DATABASE_ENV = 'hivemom'.freeze
    MIGRATIONS_DIR = 'db/migrate'.freeze
  end

  task configuration: :environment do
    @config = YAML.load_file('config/database.yml')[DATABASE_ENV]
  end

  task configure_connection: :configuration do
    ActiveRecord::Base.establish_connection @config
    ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
  end

  task migrate: :configure_connection do
    ActiveRecord::Migration.verbose = true
    if ActiveRecord::Migrator.migrate(MIGRATIONS_DIR, ENV['VERSION'])
      ENV['VERSION'].to_i
    end
  end

  desc 'Rolls the schema back to the previous version '\
       '(specify steps w/ STEP=n).'
  task rollback: :configure_connection do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
  end

  desc 'Generate migration. '\
       'format: rake db:generate_migration[create_foos_table]'
  task :generate_migration, [:name] => :environment do |_, args|
    unless args[:name]
      raise 'Must pass name. rake db:generate_migration[create_foos_table]'
    end
    timestamp = DateTime.now.strftime('%Y%m%d%H%M%S%L')
    class_name = args[:name].split('_').collect(&:capitalize).join
    filename = "#{MIGRATIONS_DIR}/#{timestamp}_#{args[:name]}.rb"
    File.open(filename, 'w') do |file|
      file.write(<<-EOS)
class #{class_name} < ActiveRecord::Migration
  def change
  end
end
      EOS
    end
    puts "Created: #{filename}"
  end
end
