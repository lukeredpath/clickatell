module Clickatelll end

%w( core-ext/hash
    clickatell/version 
    clickatell/api 
    clickatell/response 
    clickatell/connection 
    
).each do |lib|
    require File.join(File.dirname(__FILE__), lib)
end