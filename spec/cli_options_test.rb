require 'test/unit'
require 'shoulda'
require File.join(File.dirname(__FILE__), *%w[.. lib clickatell utility])

class CliOptionsTest < Test::Unit::TestCase
  
  context "Sending a message" do
    should "allow single recipients" do
      options = Clickatell::Utility::Options.parse(%w{07944123456 testing})
      assert_equal %w{07944123456}, options.recipient
    end
    
    should "allow multiple, comma-separated recipients" do
      options = Clickatell::Utility::Options.parse(%w{07944123456,07944123457 testing})
      assert_equal %w{07944123456 07944123457}, options.recipient
    end
  end
  
  context "Checking balance" do
    should "not require a recipient" do
      options = Clickatell::Utility::Options.parse(%w{-b})
      assert_nil options.recipient
    end  
  end
  
end