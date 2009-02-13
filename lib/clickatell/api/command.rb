require "cgi"
module Clickatell
  class API

    # Represents a Clickatell HTTP gateway command in the form 
    # of a complete URL (the raw, low-level request).
    class Command
      API_SERVICE_HOST = 'api.clickatell.com'

      def initialize(command_name, service = 'http', opts={})
        @command_name = command_name
        @service = service
        @options = { :secure => false }.merge(opts)
      end
  
      # Returns a URL for the given parameters (a hash).
      def with_params(param_hash)
        param_string = '?' + param_hash.map { |key, value| "#{::CGI.escape(key.to_s)}=#{::CGI.escape(value.to_s)}" }.sort.join('&')
        return URI.parse(File.join(api_service_uri, @command_name + param_string))
      end

      protected
        def api_service_uri
          protocol = @options[:secure] ? 'https' : 'http'
          api_service_host = ((Clickatell::API.api_service_host.nil? || Clickatell::API.api_service_host.empty?) ? API_SERVICE_HOST : Clickatell::API.api_service_host)
          return "#{protocol}://#{api_service_host}/#{@service}/"
        end
    end
    
  end
end
