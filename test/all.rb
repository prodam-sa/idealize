$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'
$LOAD_PATH.unshift '.'

require 'minitest/autorun'
require 'minitest/rg'
require 'test/helpers'
require 'rack/test'
require 'prodam/idealize'

Prodam::Idealize.initialize :test

Dir['test/*_test.rb', 'test/{models,controllers}/*_test.rb'].each do |test|
  load test
end
