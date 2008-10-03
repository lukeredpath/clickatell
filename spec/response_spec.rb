require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell'

module Clickatell

  describe "Response parser" do
    before do
      Clickatell::API::Error.stubs(:parse).returns(Clickatell::API::Error.new('', ''))
    end
    
    before(:each) do
      API.test_mode = false
    end
    
    it "should return hash for one-line success response" do
      Response.parse(stub('response', :body => 'k1: foo k2: bar')).should == {'k1' => 'foo', 'k2' => 'bar'}
    end
    
    it "should raise API::Error if response contains an error message" do
      proc { Response.parse(stub('response', :body => 'ERR: 001, Authentication failed')) }.should raise_error(Clickatell::API::Error)
    end
    
    describe "in test mode" do
      before(:each) do
        API.test_mode = true
      end
      
      it "should return something approximating a session_id" do
      Response.parse("pretty much anything").should == { 'OK' => 'session_id' }
      end
    end
  end
  
end