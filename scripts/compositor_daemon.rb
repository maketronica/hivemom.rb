# rubocop:disable Lint/RescueException
ENV['HIVEMOM_ENV'] = 'production'
require_relative '../config/environment.rb'
begin
  HiveMom.logger.info('Compositor Starting up')
  Dir.chdir HiveMom.root
  HiveMom::ReadingCompositor.new.run
rescue Exception => e
  HiveMom.logger.fatal("Compositor died with: #{e} : #{e.message}")
  e.backtrace.each do |line|
    HiveMom.logger.fatal(line)
  end
  raise e
ensure
  HiveMom.logger.info('Compositor Shutting Down')
end
# rubocop:enable Lint/RescueException
