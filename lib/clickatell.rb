module Clickatelll end

%w( core-ext/hash
    clickatell/api 
    clickatell/response
    
).each do |lib|
    require File.join(File.dirname(__FILE__), lib)
end
