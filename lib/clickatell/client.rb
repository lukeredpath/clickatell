require 'net/https'
require 'cgi'

module Clickatell
  class Client
    HOST = 'api.clickatell.com'
    
    attr_reader   :errors
    attr_accessor :session_id, :secure
    
    def initialize(api_id)
      @api_id = api_id
      @errors = []
    end
    
    def authenticate(username, password)
      response = perform_command('auth', :user => username, :password => password)
      if response.code.to_i == 200
        if success = response.body.match(/OK: (.*)$/)
          self.session_id = success[1]
          return true
        elsif failure = response.body.match(/ERR: (\d+), (.*)/)
          @errors << Error.new(failure[1], failure[2])
          return false
        end
      end
    end
    
    def perform_command(command, parameters = {}, service = 'http')
      client = Net::HTTP.new(HOST, (self.secure ? 443 : 80))
      client.use_ssl = self.secure
      response = client.start do |http|
        http.use_ssl = self.secure
        http.get("/#{service}/#{command}?" + query_parameters(parameters))
      end
    end
    
    class Error
      attr_reader :code, :description

      def initialize(code, description)
        @code, @description = code, description
      end
    end
    
    private
    
    def query_parameters(parameters)
      parameters.merge(:api_id => @api_id, :session_id => session_id).map { |key, value| 
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join('&')
    end
  end
  
  class AuthenticationError < StandardError
  end
end
