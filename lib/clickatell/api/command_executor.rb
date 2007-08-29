require 'net/http'

module Clickatell
  class API
   
    # Used to run commands agains the Clickatell gateway.
    class CommandExecutor
      def initialize(authentication_hash)
        @authentication_hash = authentication_hash
      end
      
      # Builds a command object and sends it using HTTP GET.
      def execute(command_name, parameters={})
        Net::HTTP.get_response(command(command_name, parameters))
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