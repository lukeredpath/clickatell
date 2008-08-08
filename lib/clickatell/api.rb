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
      
      # Set to true to enable debugging (off by default)
      attr_accessor :debug_mode
      
      # Enable secure mode (SSL)
      attr_accessor :secure_mode
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
      response = execute_command('auth', 'http',
        :api_id => api_id,
        :user => username,
        :password => password
      )
      parse_response(response)['OK']
    end
    
    # Pings the service with the specified session_id to keep the
    # session alive.
    def ping(session_id)
      execute_command('ping', 'http', :session_id => session_id)
    end
    
    # Sends a message +message_text+ to +recipient+. Recipient
    # number should have an international dialing prefix and
    # no leading zeros (unless you have set a default prefix
    # in your clickatell account centre).
    #
    # Additional options:
    #    :from - the from number/name
    #    :mo   - mobile originated flag
    #
    # Returns a new message ID if successful.
    def send_message(recipient, message_text, opts={})
      valid_options = opts.only(:from, :mo)
      valid_options.merge!(:req_feat => '48') if valid_options[:from]
      valid_options[:mo] = '1' if valid_options.delete(:mo)
      response = execute_command('sendmsg', 'http',
        {:to => recipient, :text => message_text}.merge(valid_options)
      ) 
      parse_response(response)['ID']
    end

    def send_wap_push(recipient, media_url, notification_text='', opts={})
      valid_options = opts.only(:from)
      valid_options.merge!(:req_feat => '48') if valid_options[:from]
      response = execute_command('si_push', 'mms',
        {:to => recipient, :si_url => media_url, :si_text => notification_text, :si_id => 'foo'}.merge(valid_options)
      )
      parse_response(response)['ID']
    end
    
    # Returns the status of a message. Use message ID returned
    # from original send_message call.
    def message_status(message_id)
      response = execute_command('querymsg', 'http', :apimsgid => message_id)
      parse_response(response)['Status']
    end
    
    # Returns the number of credits remaining as a float.
    def account_balance
      response = execute_command('getbalance', 'http')
      parse_response(response)['Credit'].to_f
    end

    protected
      def execute_command(command_name, service, parameters={}) #:nodoc:
        CommandExecutor.new(auth_hash, self.class.secure_mode, self.class.debug_mode).execute(command_name, service, parameters)
      end

      def parse_response(raw_response) #:nodoc:
        Clickatell::Response.parse(raw_response)
      end
      
      def auth_hash #:nodoc:
        if @auth_options[:session_id]
          { :session_id => @auth_options[:session_id] }
        elsif @auth_options[:api_id]
          { :user => @auth_options[:username],
            :password => @auth_options[:password],
            :api_id => @auth_options[:api_key] }
        else
          {}
        end
      end
    
  end
end

%w( api/command
    api/command_executor
    api/error
    api/message_status
    
).each do |lib|
    require File.join(File.dirname(__FILE__), lib)
end