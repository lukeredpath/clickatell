require 'net/http'
require 'net/https'

module Clickatell
  class API
   
   class FakeHttpResponse
     def body
       "test"
     end
   end
   
    # Used to run commands agains the Clickatell gateway.
    class CommandExecutor
      
      def initialize(authentication_hash)
        @authentication_hash = authentication_hash
        
        allow_request_recording if in_test_mode?
      end
      
      def in_test_mode?
        API.test_mode
      end
      
      # Builds a command object and sends it using HTTP GET. 
      # Will output URLs as they are requested to stdout when 
      # debugging is enabled.
      def execute(command_name, service, parameters={})
        request_uri = command(command_name, service, parameters)
        puts "[debug] Sending request to #{request_uri}" if API.debug_mode
        result = get_response(request_uri)
        if result.is_a?(Array)
          result = result.first
        end
        result
      end
      
      protected
        def command(command_name, service, parameters) #:nodoc:
          Command.new(command_name, service, :secure => API.secure_mode).with_params(
            parameters.merge(@authentication_hash)
          )
        end
        
        def get_response(uri)
          if in_test_mode?
            sms_requests << uri
            [FakeHttpResponse.new]
          else
            request = [uri.path, uri.query].join('?')

            if API.proxy_host
              http = Net::HTTP::Proxy(API.proxy_host, API.proxy_port, API.proxy_username, API.proxy_password)
            else
              http = Net::HTTP.new(uri.host, uri.port)
            end
            
            # If we're using a secure connection, validate the ssl
            # certificate
            if http.use_ssl = (uri.scheme == 'https')
              http.ca_path = API.ca_path
              http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            end
            
            if API.proxy_host
              http.start(uri.host) do |http|
                resp, body = http.get(request)
              end
            else
              http.start do |http|
                resp, body = http.get(request)
              end
            end
            
          end
        end
        
      private
      
      def allow_request_recording
        class << self
          define_method :sms_requests do
            @sms_requests ||= []
          end
        end
      end
    end 
  
  end
end
