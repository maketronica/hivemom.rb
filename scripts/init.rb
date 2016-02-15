#!/usr/bin/env ruby
### BEGIN INIT INFO
# Provides:          hivemom
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: hivemom
# Description:       hivemom
### END INIT INFO
APP_NAME = 'HiveMom'.freeze
APP_PATH = '/var/hivemom/scripts/server_control.rb'.freeze
case ARGV.first
when 'start'
  puts "Starting #{APP_NAME}..."
  system(APP_PATH, 'start')
when 'stop'
  system(APP_PATH, 'stop')
when 'status'
  system(APP_PATH, 'status')
when 'restart'
  system(APP_PATH, 'restart')
else
  puts "Usage: #{APP_NAME} {start|stop|status|restart}"
end
