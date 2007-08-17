require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell'

module Clickatell

  describe "Response parser" do
    it "should return hash for one-line success response" do
      raw_response = stub('response')
      raw_response.stub!(:body).and_return('k1: foo k2: bar')
      Response.parse(raw_response).should == {'k1' => 'foo', 'k2' => 'bar'}
    end
  end
  
end