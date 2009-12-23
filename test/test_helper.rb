require 'test/unit'
require 'shoulda'
require 'mocha'
require 'webmock'

require 'webmock/test_unit'

include WebMock
WebMock.disable_net_connect!

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[.. lib]))
