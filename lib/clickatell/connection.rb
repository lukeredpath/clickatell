module Clickatell
  
  # The Connection object provides a high-level interface to the
  # Clickatell API, handling authentication across multiple API
  # requests.
  #
  # Example:
  #   conn = Clickatell::Connection.new('your_api_key', 'joebloggs', 'secret')
  #   message_id = conn.send_message('44777123456', 'This is a test message')
  #   status = conn.message_status(message_id)
  #
  # The Connection object provides all of the public methods implemented in 
  # Clickatell::API but handles the passing of authentication options 
  # automatically so it is not required to pass any authentication_option hashes
  # into API methods that require them.
  class Connection
    
    # Returns the current Clickatell session ID.
    attr_reader :session_id
    
    # +api_key+: Your Clickatell API ID/key.
    # +username+: Your Clickatell account username.
    # +password+: Your Clickatell account password.
    def initialize(api_key, username, password)
      @api_key = api_key
      @username = username
      @password = password
    end
    
    # Manual authentication. Will create a new Clickatell session 
    # and store the session ID.
    def authenticate!
      @session_id = API.authenticate(@api_key, @username, @password)
    end
    
    protected
      # Executes the given +api_method+ by delegating to the API 
      # module, using the current session_id for authentication.
      def execute_api_call(api_method, params)
        params << {:session_id => current_session_id}
        API.send(api_method, *params)
      end
      
      # Returns the current_session_id, authenticating if one doesn't exist
      def current_session_id
        authenticate! if session_id.nil?
        session_id
      end
    
      # Dispatch any API methods to the API module.
      def method_missing(method, *args, &block)
        if API.respond_to?(method)
          execute_api_call(method, args)
        else
          super(method, args, &block)
        end
      end
  end
    
end