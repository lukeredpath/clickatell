require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/clickatell/utility'

describe "CLI options" do

  context "when sending a message" do
    it "should allow single recipients" do
      options = Clickatell::Utility::Options.parse(%w{07944123456 testing})
      options.recipient.should include("07944123456")
    end

    it "should allow multiple, comma-separated recipients" do
      options = Clickatell::Utility::Options.parse(%w{07944123456,07944123457 testing})
      options.recipient.should include(*%w{07944123456 07944123457})
    end

    it "should strip + symbols from the beginning of numbers" do
      options = Clickatell::Utility::Options.parse(%w{+447944123456 testing})
      options.recipient.should include("447944123456")
    end
  end

  context "when checking balance" do
    it "should not require a recipient" do
      options = Clickatell::Utility::Options.parse(%w{-b})
      options.recipient.should be_nil
    end
  end

end
