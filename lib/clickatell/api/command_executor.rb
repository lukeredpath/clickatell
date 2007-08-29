require 'net/http'

module Clickatell
  class API
   
    # Used to run commands agains the Clickatell gateway.
    class CommandExecutor
      def initialize(authentication_hash, debug=false)
        @authentication_hash = authentication_hash
        @debug = debug
      end
      
      # Builds a command object and sends it using HTTP GET. 
      # Will output URLs as they are requested to stdout when 
      # debugging is enabled.
      def execute(command_name, parameters={})
        request_uri = command(command_name, parameters)
        puts "[debug] Sending request to #{request_uri}" if @debug
        Net::HTTP.get_response(request_uri)
      end
      
      protected
        def command(command_name, parameters) #:nodoc:
          Command.new(command_name).with_params(
            parameters.merge(@authentication_hash)
          )
        end
    end 
  
  end
end