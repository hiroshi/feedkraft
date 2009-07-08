require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "new" do
    get :new
    assert_response :success
  end

  test "inquire" do
    pending "Need to eliminate warning about no CA" do
      post :inquire, :provider => "google"
      assert_response :redirect
    end
  end

  test "identify" do
    pending "Need to understand what OpenID providers do"
  end
end
