require 'date'
require './config/environment.rb'

class LogLoader
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def call
    start = DateTime.parse("May 13, 06:59 UTC")
    stop = DateTime.parse("May 22, 18:08 UTC")
    File.open(path).each do |line|
      begin
        next unless line.match(/\[([^\.]+)\..+HiveBot\:\:Transmission\: Sending: \{(.+)\}/)
      rescue
        next
      end
      time_string = "#{$1} MDT"
      param_string = $2

      timestamp = Time.strptime(time_string, "%Y-%m-%dT%H:%M:%S %z").getutc
      next if timestamp < start
      next if timestamp > stop
      params = param_string.split(',').map(&:strip).map do |e|
        e.gsub(/\"/,'').split('=>')
      end.to_h
      params['sampled_at'] = timestamp
      params['composite'] = 'instant'
      success = false
      until(success) do
        begin
          reading = HiveMom::Reading.find_or_create_by(params)
          if reading.valid?
	    success = true
          else
            puts reading.errors.inspect
            raise
          end
        rescue
          puts 'rescuing'
          sleep 1
          puts 'resuming'
        end
      end
    end
  end
end

LogLoader.new('./hivebot2.log').call
LogLoader.new('./hivebot3.log').call
