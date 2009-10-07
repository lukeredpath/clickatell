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
    
    it "should return array of hashes for multi-line success response" do
      Response.parse(stub('response', :body => "k1: foo\nk2: bar")).should == [{'k1' => 'foo'}, {'k2' => 'bar'}]
    end
    
    it "should raise API::Error if response contains an error message" do
      proc { Response.parse(stub('response', :body => 'ERR: 001, Authentication failed')) }.should raise_error(Clickatell::API::Error)
    end

    {
      '001' => 1, '002' => 2,  '003' => 3,  '004' => 4,
      '005' => 5, '006' => 6,  '007' => 7,  '008' => 8,
      '009' => 9, '010' => 10, '011' => 11, '012' => 12
    }.each do |status_str, status_int|
      it "should parse a message status code of #{status_int} when the response body contains a status code of #{status_str}" do
        Response.parse(stub('response', :body => "ID: 0d1d7dda17d5a24edf1555dc0b679d0e Status: #{status_str}")).should == {'ID' => '0d1d7dda17d5a24edf1555dc0b679d0e', 'Status' => status_int}
      end
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