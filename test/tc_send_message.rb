$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'tc_send_message'
require 'clickatell'
require 'cgi'

class TcSendMessage < Test::Unit::TestCase
  # define phone number to send msg from
  @@from_number = '14085059096'
  # define phone number to send msg to
  @@to_number = '16502438095'
  # define push content
  @@img_url = 'http://vjoe.metamaki.com/gifts/hippo/hippo.png'

  Clickatell::API.debug_mode = true
  @@api = Clickatell::API::authenticate('3111117', 'zhaolu', 'flute225')

#  def test_send_message
#    msg_id = @@api.send_message(@@to_number, 'Hello from Virtual Joe: ' + @@img_url +' ' + CGI::escape(@@img_url))
#    assert_not_nil(msg_id)
#  end

  def test_wap_push
    msg_id = @@api.send_wap_push(@@to_number, @@img_url, 'Hello from Virtual Joe.')
    assert_not_nil(msg_id)
  end
end
