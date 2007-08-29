module Clickatell
  class API
   
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