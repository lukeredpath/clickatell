require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell'

module Clickatell
  describe "API::CommandExecutor" do
    it "should have test mode" do
      executor = API::CommandExecutor.new({}, false, false, :test_mode)
      executor.should be_in_test_mode
    end
    
    it "should default to not test mode" do
      executor = API::CommandExecutor.new({})
      executor.should_not be_in_test_mode
    end

    describe "#execute" do
      describe "in non-test mode" do
        before(:each) do
          @executor = API::CommandExecutor.new({})
        end
        
        it "should not record requests" do
          @executor.should_not respond_to(:sms_requests)
        end

        describe "without a proxy" do
          before do
            @http = mock()
            @http.expects(:use_ssl=).with(false)
            @http.expects(:start).returns([])
            Net::HTTP.expects(:new).with(API::Command::API_SERVICE_HOST, 80).returns(@http)
          end

          it "should execute commands through the proxy" do
            @executor.execute("foo", "http")
          end
        end

        describe "with a proxy" do
          before do
            API.proxy_host     = @proxy_host     = "proxy.example.com"
            API.proxy_port     = @proxy_port     = "1234"
            API.proxy_username = @proxy_username = "joeschlub"
            API.proxy_password = @proxy_password = "secret"

            @http = mock()
            @http.expects(:start).with(API::Command::API_SERVICE_HOST).returns([])
            Net::HTTP.expects(:Proxy).with(@proxy_host, @proxy_port, @proxy_username, @proxy_password).returns(@http)
          end

          it "should execute commands through the proxy" do
            @executor.execute("foo", "http")
          end
        end
      end
      
      describe "in test mode" do
        before(:each) do
          @params = {:foo => 1, :bar => 2}
          @executor = API::CommandExecutor.new(@params, false, false, :test_mode)
        end
        
        it "should not make any network calls" do
          Net::HTTP.expects(:new).never
          @executor.execute("foo", "http")
        end
        
        it "should start with an empty request collection" do
          @executor.sms_requests.should be_empty
        end
        
        it "should record sms requests" do
          @executor.execute("bar", "http")
          @executor.sms_requests.should_not be_empty
        end
        
        it "should record a request for each call" do
          @executor.execute("wibble", "http")
          @executor.sms_requests.size.should == 1
          @executor.execute("foozle", "http")
          @executor.sms_requests.size.should == 2
        end
        
        it "should return a response that approximates a true Net::HttpResponse" do
          response = @executor.execute("throat-warbler", "http")
          response.body.should == "test"
        end
        
        describe "each recorded request" do
          it "should return the command information" do
            command = "rum_tum_tum"
            @executor.execute(command, "http")
            
            uri = @executor.sms_requests.first
            uri.host.should == "api.clickatell.com"
            uri.path.should include(command)
            @params.collect { |k, v| "#{k}=#{v}"}.each do |query_parameter|
              uri.query.should include(query_parameter)
            end
          end
        end
      end
    end
  end
end