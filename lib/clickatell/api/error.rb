module Clickatell
  class API
  
    # Clickatell API Error exception.
    class Error < StandardError
      attr_reader :code, :message, :response
      
      def initialize(code, message, response)
        @code, @message, @response = code, message, response
      end
      
      # Creates a new Error from a Clickatell HTTP response string
      # e.g.:
      #
      #  Error.parse("ERR: 001, Authentication error")
      #  # =>  #<Clickatell::API::Error code='001' message='Authentication error'>
      def self.parse(response)
        response.body.split("\n").map do |line|
          if line =~ /^ERR: (\d+), (.*)$/
            code, message = $1.to_i, $2
            break
          end
        end
        self.new(code, message, response)
      end
    end
  
  end
end