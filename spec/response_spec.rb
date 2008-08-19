require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell'

module Clickatell

  describe "Response parser" do
    before do
      Clickatell::API::Error.stubs(:parse).returns(Clickatell::API::Error.new('', ''))
    end
    
    it "should return hash for one-line success response" do
      Response.parse(stub('response', :body => 'k1: foo k2: bar')).should == {'k1' => 'foo', 'k2' => 'bar'}
    end
    
    it "should raise API::Error if response contains an error message" do
      proc { Response.parse(stub('response', :body => 'ERR: 001, Authentication failed')) }.should raise_error(Clickatell::API::Error)
    end
  end
  
end