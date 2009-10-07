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
          # YAML.load converts integer strings that have leading zeroes into integers
          # using octal rather than decimal.  This isn't what we want, so we'll strip out any
          # leading zeroes in numbers here.
          response_fields = line.scan(PARSE_REGEX)
          response_fields = response_fields.collect { |field| field.gsub(/\b0+(\d+)\b/, '\1') }
          YAML.load(response_fields.join("\n"))
        end
        results.length == 1 ? results.first : results
      end
      
    end

  end
end