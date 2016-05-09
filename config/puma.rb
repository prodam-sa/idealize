#!/usr/bin/env puma

# directory '/u/apps/lolcat'

@environment = ENV['RACK_ENV'] || 'development'

environment @environment

daemonize true if @environment == 'production'

pidfile "tmp/idealize-#{@environment}.pid"

state_path "tmp/idealize-#{@environment}.state"

threads 0, 16

bind "unix:///tmp/idealize-#{@environment}.sock"

on_restart do
  puts 'On restart...'
end

workers 0

tag 'idealize'
