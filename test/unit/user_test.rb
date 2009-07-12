require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "create multiple no name users" do
    assert_equal 1, User.count(:conditions => 'name IS NULL')
    User.create(:identity => "http://new.example.com")
    assert_equal 2, User.count(:conditions => 'name IS NULL')
  end
end
