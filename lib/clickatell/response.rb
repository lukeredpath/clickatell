require 'yaml'

module Clickatell
  
  # Used to parse HTTP responses returned from Clickatell API calls.
  class Response

    class << self
      PARSE_REGEX = /[A-Za-z0-9]+:.*?(?:(?=[A-Za-z0-9]+:)|$)/
      
      # Returns the HTTP response body data as a hash.
      def parse(http_response)
        return { 'OK' => 'session_id' } if API.test_mode
        
        if http_response.body.scan(/ERR/).any?
          raise Clickatell::API::Error.parse(http_response.body)
        end
        results = http_response.body.split("\n").map do |line|
          YAML.load(line.scan(PARSE_REGEX).join("\n"))
        end
        results.length == 1 ? results.first : results
      end
      
    end

  end
end