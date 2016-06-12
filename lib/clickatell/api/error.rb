module Clickatell
  class API
  
    # Clickatell API Error exception.
    class Error < StandardError
      attr_reader :code, :message
      
      def initialize(code, message)
        @code, @message = code, message
      end
      
      # Creates a new Error from a Clickatell HTTP response string
      # e.g.:
      #
      #  Error.parse("ERR: 001, Authentication error")
      #  # =>  #<Clickatell::API::Error code='001' message='Authentication error'>
      def self.parse(error_string)
        if error_string =~ /^ERR: (\d+), (.*)$/
          self.new($1, $2)
        else
          self.new(nil, error_string)
        end
      end
    end
  
  end
end