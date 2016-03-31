# rubocop:disable Lint/RescueException
ENV['HIVEMOM_ENV'] = 'production'
require_relative '../config/environment.rb'
begin
  HiveMom.logger.info('Starting up')
  Dir.chdir HiveMom.root
  Rack::Server.start(app: HiveMom::Server.new, Host: '192.168.2.1')
rescue Exception => e
  HiveMom.logger.fatal("Mom died with: #{e} : #{e.message}")
  e.backtrace.each do |line|
    HiveMom.logger.fatal(line)
  end
  raise e
ensure
  HiveMom.logger.info('Shutting Down')
end
# rubocop:enable Lint/RescueException
