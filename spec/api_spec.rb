require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell'

module Clickatell
  
  describe "API Command" do
    before do
      @command = API::Command.new('cmdname')
    end
    
    it "should return encoded URL for the specified command and parameters" do
      url = @command.with_params(:param_one => 'abc', :param_two => '123')
      url.should == URI.parse("http://api.clickatell.com/http/cmdname?param_one=abc&param_two=123")
    end
    
    it "should URL encode any special characters in parameters" do
      url = @command.with_params(:param_one => 'abc', :param_two => 'hello world')
      url.should == URI.parse("http://api.clickatell.com/http/cmdname?param_one=abc&param_two=hello%20world")
    end
  end
  
  describe "Secure API Command" do
    before do
      @command = API::Command.new('cmdname', :secure => true)
    end
    
    it "should use HTTPS" do
      url = @command.with_params(:param_one => 'abc', :param_two => '123')
      url.should == URI.parse("https://api.clickatell.com/http/cmdname?param_one=abc&param_two=123")
    end
  end
  
  describe "Command executor" do
    it "should create an API command and send it via HTTP get, returning the raw http response" do
      API::Command.should_receive(:new).with('cmdname').and_return(cmd=mock('command'))
      cmd.should_receive(:with_params).with(:param_one => 'foo').and_return(uri=mock('uri'))
      Net::HTTP.should_receive(:get_response).with(uri).and_return(raw_response=mock('http response'))
      API.send(:execute_command, 'cmdname', :param_one => 'foo').should == raw_response
    end
  end
  
  describe "API" do
    it "should return session_id for successful authentication" do
      API.should_receive(:execute_command).with('auth',
        :api_id => '1234',
        :user => 'joebloggs',
        :password => 'superpass'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('OK' => 'new_session_id')        
      API.authenticate('1234', 'joebloggs', 'superpass').should == 'new_session_id'
    end
    
    it "should support ping" do
      API.should_receive(:execute_command).with('ping', :session_id => 'abcdefg').and_return(response=mock('response'))
      API.ping('abcdefg').should == response
    end
    
    it "should support sending messages with authentication, returning the message id" do
      API.should_receive(:execute_command).with('sendmsg',
        :api_id => '1234',
        :user => 'joebloggs',
        :password => 'superpass',
        :to => '4477791234567',
        :text => 'hello world'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('ID' => 'message_id')      
      API.send_message('4477791234567', 'hello world',
        :username => 'joebloggs', :password => 'superpass', :api_key => '1234'
      ).should == 'message_id'
    end
    
    it "should support sending messages with pre-auth, returning the message id" do
      API.should_receive(:execute_command).with('sendmsg',
        :session_id => 'abcde',
        :to => '4477791234567',
        :text => 'hello world'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('ID' => 'message_id')
      API.send_message('4477791234567', 'hello world', :session_id => 'abcde').should == 'message_id'
    end
    
    it "should support message status query with authentication, returning message status" do
      API.should_receive(:execute_command).with('querymsg',
        :api_id => '1234',
        :user => 'joebloggs',
        :password => 'superpass',
        :apimsgid => 'messageid'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('ID' => 'message_id', 'Status' => 'message_status')
      API.message_status('messageid',
        :username => 'joebloggs', :password => 'superpass', :api_key => '1234'
      ).should == 'message_status'
    end
    
    it "should support message status query with pre-auth" do
      API.should_receive(:execute_command).with('querymsg',
        :session_id => 'abcde',
        :apimsgid => 'messageid'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('ID' => 'message_id', 'Status' => 'message_status')
      API.message_status('messageid', :session_id => 'abcde').should == 'message_status'
    end
    
    it "should support balance query with authentication, returning number of credits as a float" do
      API.should_receive(:execute_command).with('getbalance',
        :api_id => '1234',
        :user => 'joebloggs',
        :password => 'superpass'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('Credit' => '10.0')
      API.account_balance(:username => 'joebloggs', :password => 'superpass', :api_key => '1234').should == 10.0
    end
    
    it "should support balance query with pre-auth, returning number of credits as a float" do
      API.should_receive(:execute_command).with('getbalance',
        :session_id => 'abcde'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('Credit' => '10.0')
      API.account_balance(:session_id => 'abcde').should == 10.0
    end
    
    it "should raise an API::Error if the response parser raises" do
      API.stub!(:execute_command)
      Response.stub!(:parse).and_raise(Clickatell::API::Error.new('', ''))
      proc { API.account_balance({}) }.should raise_error(Clickatell::API::Error)
    end
  end
  
  describe "API Error" do
    it "should parse http response string to create error" do
      response_string = "ERR: 001, Authentication error"
      error = Clickatell::API::Error.parse(response_string)
      error.code.should == '001'
      error.message.should == 'Authentication error'
    end
  end
  
end