module Clickatell
  class API
   
    class MessageStatus
      STATUS_MAP = {
        '001'  => 'Message unknown',
        '002'  => 'Message queued',
        '003'  => 'Delivered to gateway',
        '004'  => 'Received by recipient',
        '005'  => 'Error with message',
        '006'  => 'User cancelled messaged delivery',
        '007'  => 'Error delivering message',
        '008'  => 'OK',
        '009'  => 'Routing error',
        '010' => 'Message expired',
        '011' => 'Message queued for later delivery',
        '012' => 'Out of credit'
      }
      
      def self.[](code)
        STATUS_MAP[code]
      end
    end 
  
  end
end