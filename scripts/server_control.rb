#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
Daemons.run(File.expand_path('../server_daemon.rb', __FILE__))
