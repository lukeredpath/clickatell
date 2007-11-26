module Clickatell #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 4
    TINY  = 1

    STRING = [MAJOR, MINOR, TINY].join('.')
    
    def self.to_s
      STRING
    end
  end
end
