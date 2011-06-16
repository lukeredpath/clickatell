require 'rubygems'
require 'rspec'
require 'mocha'
require 'test/unit'

RSpec.configure do |config|
  config.mock_framework = :mocha
end