# encoding: utf-8

$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'

require 'prodam/idealize'

Prodam::Idealize.routing.each do |path, controller|
  map path do
    run controller
  end
end
