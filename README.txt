Clickatell Ruby Gem

1. Basic Usage

To use this gem, you will need sign up for an account at www.clickatell.com. 
Once you are registered and logged into your account centre, you should add 
an HTTP API connection to your account. This will give you your API_ID.

You can now use the library directly. You will need your API_ID as well as your
account username and password.

  require 'rubygems'
  require 'clickatell'
  
  connection = Clickatell::Connection.new(
    'your_api_id',
    'your_username',
    'your_password'
  )
  connection.send_message('447771234567', 'Hello from clickatell')

  
2. Command-line SMS Utility

The Clickatell gem also comes with a command-line utility that will allow you
to send an SMS directly from the command-line. 

You will need to create a YAML configuration file in your home directory, in a 
file called .clickatell that resembles the following:

  # ~/.clickatell
  api_key: your_api_id
  username: your_username
  password: your_password
  
You can then use the sms utility to send a message to a single recipient:

  sms 447771234567 'Hello from clickatell'