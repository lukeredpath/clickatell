require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell'

module Clickatell

  describe Connection, ' when unauthenticated' do
    it "should authenticate and store session_id before sending command" do
      connection = Connection.new('my_api_key', 'myusername', 'mypassword')
      API.should_receive(:authenticate).with('my_api_key', 'myusername', 'mypassword').and_return('new_session_id')
      API.should_receive(:send_message).with('4477791234567', 'hello world', :session_id => 'new_session_id')
      connection.send_message('4477791234567', 'hello world')
    end
  end
  
  describe Connection, ' when authenticated' do
    it "should send command with session_id without re-authenticating" do
      connection = Connection.new('my_api_key', 'myusername', 'mypassword')
      connection.stub!(:session_id).and_return('session_id')
      API.should_receive(:authenticate).never
      API.should_receive(:send_message).with('4477791234567', 'hello world', :session_id => 'session_id')
      connection.send_message('4477791234567', 'hello world')
    end
  end
  
end