require 'net/http'

module Clickatell  
  module API
    
    class << self
      
      def authenticate(api_id, username, password)
        response = execute_command('auth',
          :api_id => api_id,
          :user => username,
          :password => password
        )
        parse_response(response)['OK']
      end
      
      def ping(session_id)
        execute_command('ping', :session_id => session_id)
      end
      
      def send_message(recipient, message_text, auth_options)
        response = execute_command('sendmsg', {
          :to => recipient,
          :text => message_text
        }.merge( auth_hash(auth_options) )) 
        parse_response(response)['ID']
      end
      
      def message_status(message_id, auth_options)
        response = execute_command('querymsg', {
          :apimsgid => message_id 
        }.merge( auth_hash(auth_options) ))
        parse_response(response)['Status']
      end

      protected
        def execute_command(command_name, parameters)
          Net::HTTP.get_response(
            Command.new(command_name).with_params(parameters)
          )
        end
        
        def parse_response(raw_response)
          Clickatell::Response.parse(raw_response)
        end
        
        def auth_hash(options)
          if options[:session_id]
            return {
              :session_id => options[:session_id]
            }
          else
            return {
              :user => options[:username],
              :password => options[:password],
              :api_id => options[:api_key]
            }
          end
      end
      
    end
    
    class Command
      API_SERVICE_HOST = 'api.clickatell.com'

      def initialize(command_name, opts={})
        @command_name = command_name
        @options = { :secure => false }.merge(opts)
      end

      def with_params(param_hash)
        param_string = '?' + param_hash.map { |key, value| "#{key}=#{value}" }.join('&')
        return URI.parse(File.join(api_service_uri, @command_name + URI.encode(param_string)))
      end

      protected
        def api_service_uri
          protocol = @options[:secure] ? 'https' : 'http'
          return "#{protocol}://#{API_SERVICE_HOST}/http/"
        end
    end
    
  end
end