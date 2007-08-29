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
    it "should create an API command with auth params and send it via HTTP get, returning the raw http response" do
      executor = API::CommandExecutor.new(:session_id => '12345')
      API::Command.should_receive(:new).with('cmdname').and_return(cmd=mock('command'))
      cmd.should_receive(:with_params).with(:param_one => 'foo', :session_id => '12345').and_return(uri=mock('uri'))
      Net::HTTP.should_receive(:get_response).with(uri).and_return(raw_response=mock('http response'))
      executor.execute('cmdname', :param_one => 'foo').should == raw_response
    end
  end
  
  describe "API" do
    before do
      API::CommandExecutor.should_receive(:new).with(
        :session_id => '1234'
      ).and_return(@executor = mock('command executor'))
      @api = API.new(:session_id => '1234')
    end
    
    it "should return session_id for successful authentication" do
      @executor.should_receive(:execute).with('auth',
        :api_id => '1234',
        :user => 'joebloggs',
        :password => 'superpass'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('OK' => 'new_session_id')        
      @api.authenticate('1234', 'joebloggs', 'superpass').should == 'new_session_id'
    end
    
    it "should support ping" do
      @executor.should_receive(:execute).with('ping', :session_id => 'abcdefg').and_return(response=mock('response'))
      @api.ping('abcdefg').should == response
    end
    
    it "should support sending messages, returning the message id" do
      @executor.should_receive(:execute).with('sendmsg',
        :to => '4477791234567',
        :text => 'hello world'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('ID' => 'message_id')      
      @api.send_message('4477791234567', 'hello world').should == 'message_id'
    end
    
    it "should support sending messages with custom from number, returning the message id" do
      @executor.should_receive(:execute).with('sendmsg',
        :to => '4477791234567',
        :text => 'hello world',
        :from => 'LUKE'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('ID' => 'message_id')
      @api.send_message('4477791234567', 'hello world', :from => 'LUKE')
    end
    
    it "should ignore any invalid parameters when sending message" do
      @executor.should_receive(:execute).with('sendmsg',
        :to => '4477791234567',
        :text => 'hello world',
        :from => 'LUKE'
      ).and_return(response=mock('response'))
      Response.stub!(:parse).and_return('ID' => 'foo')
      @api.send_message('4477791234567', 'hello world', :from => 'LUKE', :any_old_param => 'test')
    end
    
    it "should support message status query, returning message status" do
      @executor.should_receive(:execute).with('querymsg',
        :apimsgid => 'messageid'
      ).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('ID' => 'message_id', 'Status' => 'message_status')
      @api.message_status('messageid').should == 'message_status'
    end
    
    it "should support balance query, returning number of credits as a float" do
      @executor.should_receive(:execute).with('getbalance', {}).and_return(response=mock('response'))
      Response.should_receive(:parse).with(response).and_return('Credit' => '10.0')
      @api.account_balance.should == 10.0
    end
    
    it "should raise an API::Error if the response parser raises" do
      @executor.stub!(:execute)
      Response.stub!(:parse).and_raise(Clickatell::API::Error.new('', ''))
      proc { @api.account_balance }.should raise_error(Clickatell::API::Error)
    end
  end
  
  describe API, ' when authenticating' do
    it "should authenticate to retrieve a session_id and return a new API instance using that session id" do
      API.stub!(:new).and_return(api=mock('api'))
      api.should_receive(:authenticate).with('my_api_key', 'joebloggs', 'mypassword').and_return('new_session_id')
      api.should_receive(:auth_options=).with(:session_id => 'new_session_id')
      API.authenticate('my_api_key', 'joebloggs', 'mypassword')
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