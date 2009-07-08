require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "edit" do
    login_as :taro
    get :edit, :id => users(:taro).id
    assert_response :success
  end

  test "edit without identification" do
    login_as :jiro
    get :edit, :id => users(:taro).id
    assert_response :forbidden
  end

  test "update" do
    login_as :taro
    put :update, :id => users(:taro).id, :user => {:name => "michael"}
    assert_redirected_to root_path
    assert_equal "michael", users(:taro, :reload).name
  end

  test "update without identification" do
    login_as :jiro
    put :update, :id => users(:taro).id, :user => {:name => "michael"}
    assert_response :forbidden
    assert_equal "taro", users(:taro, :reload).name
  end
end
