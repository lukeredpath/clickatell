require 'net/http'
require 'net/https'

module Clickatell
  class API
   
    # Used to run commands agains the Clickatell gateway.
    class CommandExecutor
      def initialize(authentication_hash, secure=false, debug=false)
        @authentication_hash = authentication_hash
        @debug = debug
        @secure = secure
      end
      
      # Builds a command object and sends it using HTTP GET. 
      # Will output URLs as they are requested to stdout when 
      # debugging is enabled.
      def execute(command_name, service, parameters={})
        request_uri = command(command_name, service, parameters)
        puts "[debug] Sending request to #{request_uri}" if @debug
        get_response(request_uri).first
      end
      
      protected
        def command(command_name, service, parameters) #:nodoc:
          Command.new(command_name, service, :secure => @secure).with_params(
            parameters.merge(@authentication_hash)
          )
        end
        
        def get_response(uri)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')
          http.start do |http|
            resp, body = http.get([uri.path, uri.query].join('?'))
          end
        end
    end 
  
  end
end