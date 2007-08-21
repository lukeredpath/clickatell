require 'yaml'

module Clickatell
  
  # Used to parse HTTP responses returned from Clickatell API calls.
  class Response

    class << self
      PARSE_REGEX = /[A-Za-z0-9]+:.*?(?:(?=[A-Za-z0-9]+:)|$)/
      
      # Returns the HTTP response body data as a hash.
      def parse(http_response)
        if http_response.body.scan(/ERR/).any?
          raise Clickatell::API::Error.parse(http_response.body)
        end
        YAML.load(http_response.body.scan(PARSE_REGEX).join("\n"))
      end
      
    end

  end
end