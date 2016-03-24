$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'app'
$LOAD_PATH.unshift '.'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'prodam/idealize'
require 'test/helpers'

Dir['test/*_test.rb', 'test/{models,controllers}/*_test.rb'].each do |test|
  load test
end
