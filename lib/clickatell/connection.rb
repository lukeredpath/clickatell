module Clickatell
  
  class Connection
    attr_reader :session_id
    
    def initialize(api_key, username, password)
      @api_key = api_key
      @username = username
      @password = password
    end
    
    def authenticate!
      @session_id = API.authenticate(@api_key, @username, @password)
    end
    
    protected
      def execute_api_call(api_method, params)
        params << {:session_id => current_session_id}
        API.send(api_method, *params)
      end
      
      def current_session_id
        authenticate! if session_id.nil?
        session_id
      end
    
      def method_missing(method, *args, &block)
        if API.respond_to?(method)
          execute_api_call(method, args)
        else
          super(method, args, &block)
        end
      end
  end
    
end