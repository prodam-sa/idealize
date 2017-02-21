@environment = ENV['RACK_ENV'] || 'development'

environment @environment

tag 'idealize'

if @environment == 'production'
  daemonize true
  bind "unix:///tmp/idealize-#{@environment}.sock"
  stdout_redirect "log/#{@environment}.out.log", "log/#{@environment}.err.log", true
else
  daemonize false
  quiet false
  bind 'tcp://0.0.0.0:8091'
end

pidfile "tmp/idealize-#{@environment}.pid"

state_path "tmp/idealize-#{@environment}.state"

threads 0, 16

on_restart do
  puts 'IDEALIZE: Restart...'
end

workers 0
