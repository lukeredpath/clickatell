require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell'

module Clickatell

  describe "Response parser" do
    before do
      Clickatell::API::Error.stub!(:parse).and_return(Clickatell::API::Error.new('', ''))
    end
    
    it "should return hash for one-line success response" do
      raw_response = stub('response')
      raw_response.stub!(:body).and_return('k1: foo k2: bar')
      Response.parse(raw_response).should == {'k1' => 'foo', 'k2' => 'bar'}
    end
    
    it "should raise API::Error if response contains an error message" do
      raw_response = stub('response')
      raw_response.stub!(:body).and_return('ERR: 001, Authentication failed')
      proc { Response.parse(raw_response) }.should raise_error(Clickatell::API::Error)
    end
  end
  
end