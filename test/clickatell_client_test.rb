require 'test_helper'
require 'clickatell/client'

class ClickatellClientTest < Test::Unit::TestCase
  
  context "Clickatell::Client" do
    setup do
      @client = Clickatell::Client.new('my_api_id')
    end
    
    context "when authenticating" do
      setup do
        stub_request(:get, %r{http://api.clickatell.com/http/auth}).to_return(
          :status => 200, 
          :body   => %{
            OK: bfe78666f33dcd6f0991b1340f4a089b
          }
        )
      end
      
      should "send a GET request to the auth URL with the provided credentials" do
        @client.authenticate('joebloggs', 'letmein')
        assert_requested :get, %r{http://api.clickatell.com/http/auth?.*password=letmein&user=joebloggs}
      end

      should "set store the returned session ID" do
        @client.authenticate('joebloggs', 'letmein')
        assert_equal 'bfe78666f33dcd6f0991b1340f4a089b', @client.session_id
      end
      
      should "should return true" do
        assert @client.authenticate('joebloggs', 'letmein')
      end
    end
    
    context "when authentication fails" do
      setup do
        stub_request(:get, %r{http://api.clickatell.com/http/auth}).to_return(
          :status => 200, 
          :body   => %{
            ERR: 001, Authentication failed
          }
        )
      end

      should "return false" do
        assert !@client.authenticate('joebloggs', 'letmein')
      end
      
      should "store the error" do
        @client.authenticate('joebloggs', 'letmein')
        error = @client.errors.pop
        assert_equal '001', error.code
        assert_equal 'Authentication failed', error.description
      end
    end

    context "when performing a command" do
      setup do
        @client.session_id = 'my_session_id'
        stub_request(:get, %r{http://api.clickatell.com/})
      end

      should "send a GET request to the correct URI" do
        @client.perform_command('ping')
        assert_requested :get, %r{http://api.clickatell.com/http/ping}
      end
      
      should "pass the API ID as a query string parameter" do
        @client.perform_command('ping')
        assert_requested :get, %r{http://api.clickatell.com/http/ping?.*api_id=my_api_id}
      end
      
      should "pass the session ID as a query string parameter" do
        @client.perform_command('ping')
        assert_requested :get, %r{http://api.clickatell.com/http/ping?.*session_id=my_session_id}
      end
      
      should "pass any additional parameters in the query string" do
        @client.perform_command('ping', :foo => 'bar', :baz => 'qux')
        assert_requested :get, %r{http://api.clickatell.com/http/ping?.*baz=qux&foo=bar}
      end
      
      should "allow an alternative service to be specified" do
        @client.perform_command('ping', {}, 'mms')
        assert_requested :get, %r{http://api.clickatell.com/mms/ping}
      end
    end
    
    context "in secure mode" do
      setup do
        @client.secure = true
      end

      should "perform commands using HTTPS" do
        stub_request(:get, %r{https://api.clickatell.com:443/})
        @client.perform_command('ping')
        assert_requested :get, %r{https://api.clickatell.com/http/ping}
      end
    end
  end
  
end