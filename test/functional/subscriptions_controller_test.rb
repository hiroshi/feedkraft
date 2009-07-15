require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  test "create" do
    @request.env["HTTP_REFERER"] = root_path
    login_as :taro
    assert_difference "Subscription.count" do
      post :create, :subscription => {:filter_id => filters(:news).id}
    end
    assert_redirected_to root_path
  end

  test "feed" do
    get :feed, :key => subscriptions(:blog_for_taro).key
    assert_response :success
  end

  test "destroy" do
    @request.env["HTTP_REFERER"] = root_path
    login_as :taro
    assert_difference "Subscription.count", -1 do
      delete :destroy, :key => subscriptions(:blog_for_taro).key
    end
    assert_redirected_to root_path
  end
end
