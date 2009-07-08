require 'test_helper'

class FeedsControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
  end

  test "feed" do
    get :feed, :url => "test/fixtures/files/mycom.rss1"
    assert_response :success
  end
end
