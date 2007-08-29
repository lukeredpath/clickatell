require 'net/http'

module Clickatell
  # This module provides the core implementation of the Clickatell
  # HTTP service.
  class API
    attr_accessor :auth_options
    
    class << self
      # Authenticates using the given credentials and returns an 
      # API instance with the authentication options set to use the 
      # resulting session_id.
      def authenticate(api_id, username, password)
        api = self.new
        session_id = api.authenticate(api_id, username, password)
        api.auth_options = { :session_id => session_id }
        api
      end
    end
    
    # Creates a new API instance using the specified +auth options+.
    # +auth_options+ is a hash containing either a :session_id or 
    # :username, :password and :api_key.
    #
    # Some API calls (authenticate, ping etc.) do not require any 
    # +auth_options+. +auth_options+ can be updated using the accessor methods.
    def initialize(auth_options={})
      @auth_options = auth_options
    end
    
    # Authenticates using the specified credentials. Returns
    # a session_id if successful which can be used in subsequent
    # API calls.
    def authenticate(api_id, username, password)
      response = execute_command('auth',
        :api_id => api_id,
        :user => username,
        :password => password
      )
      parse_response(response)['OK']
    end
    
    # Pings the service with the specified session_id to keep the
    # session alive.
    def ping(session_id)
      execute_command('ping', :session_id => session_id)
    end
    
    # Sends a message +message_text+ to +recipient+. Recipient
    # number should have an international dialing prefix and
    # no leading zeros (unless you have set a default prefix
    # in your clickatell account centre).
    #
    # Additional options:
    #    :from - the from number/name
    #
    # Returns a new message ID if successful.
    def send_message(recipient, message_text, opts={})
      valid_options = opts.only(:from)
      response = execute_command('sendmsg',
        {:to => recipient, :text => message_text}.merge(valid_options)
      ) 
      parse_response(response)['ID']
    end
    
    # Returns the status of a message. Use message ID returned
    # from original send_message call.
    def message_status(message_id)
      response = execute_command('querymsg', :apimsgid => message_id)
      parse_response(response)['Status']
    end
    
    # Returns the number of credits remaining as a float.
    def account_balance
      response = execute_command('getbalance')
      parse_response(response)['Credit'].to_f
    end

    protected
      def execute_command(command_name, parameters={}) #:nodoc:
        CommandExecutor.new(auth_hash).execute(command_name, parameters)
      end

      def parse_response(raw_response) #:nodoc:
        Clickatell::Response.parse(raw_response)
      end
      
      def auth_hash #:nodoc:
        @authentication_hash ||= if @auth_options[:session_id]
          { :session_id => @auth_options[:session_id] }
        else
          { :user => @auth_options[:username],
            :password => @auth_options[:password],
            :api_id => @auth_options[:api_key] }
        end
      end
    
    # Represents a Clickatell HTTP gateway command in the form 
    # of a complete URL (the raw, low-level request).
    class Command
      API_SERVICE_HOST = 'api.clickatell.com'

      def initialize(command_name, opts={})
        @command_name = command_name
        @options = { :secure => false }.merge(opts)
      end
      
      # Returns a URL for the given parameters (a hash).
      def with_params(param_hash)
        param_string = '?' + param_hash.map { |key, value| "#{key}=#{value}" }.sort.join('&')
        return URI.parse(File.join(api_service_uri, @command_name + URI.encode(param_string)))
      end

      protected
        def api_service_uri
          protocol = @options[:secure] ? 'https' : 'http'
          return "#{protocol}://#{API_SERVICE_HOST}/http/"
        end
    end
    
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
        error_details = error_string.split(':').last.strip
        code, message = error_details.split(',').map { |s| s.strip }
        self.new(code, message)
      end
    end
    
    class MessageStatus
      STATUS_MAP = {
        1  => 'Message unknown',
        2  => 'Message queued',
        3  => 'Delivered to gateway',
        4  => 'Received by recipient',
        5  => 'Error with message',
        6  => 'User cancelled messaged delivery',
        7  => 'Error delivering message',
        8  => 'OK',
        9  => 'Routing error',
        10 => 'Message expired',
        11 => 'Message queued for later delivery',
        12 => 'Out of credit'
      }
      
      def self.[](code)
        STATUS_MAP[code]
      end
    end
    
  end
end