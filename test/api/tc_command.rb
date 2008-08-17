# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'clickatell'

class TcCommand < Test::Unit::TestCase
  def test_api_service_uri
    api_service_uri_helper('http', 'send_msg')
    api_service_uri_helper('mms', 'si_push')
  end

  private
  def api_service_uri_helper(service, cmd_name)
    cmd = Clickatell::API::Command.new(cmd_name, service)
    path = cmd.with_params({}).path
    assert_match(/#{service}/, path)
    assert_match(/#{cmd_name}/, path)
  end
end
