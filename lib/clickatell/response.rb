require 'yaml'

module Clickatell
  class Response

    class << self
      PARSE_REGEX = /[A-Za-z0-9]+:.*?(?:(?=[A-Za-z0-9]+:)|$)/
      
      def parse(http_response)
        YAML.load(http_response.body.scan(PARSE_REGEX).join("\n"))
      end
      
    end

  end
end