ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  # Add more helper methods to be used by all tests here...
  def fixture_file_read(path)
    File.read(File.join(Rails.root,"test","fixtures",path))
  end
  
  def login_as(user)
    @controller.set_current_user users(user)
  end
  
  def pending(message=nil, &block)
    puts "PENDING: #{caller[-1]}: #{message}"
  end
end
