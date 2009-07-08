require 'test_helper'

class FiltersControllerTest < ActionController::TestCase
  test "latest" do
    get :latest
    assert_response :success
  end

  test "new" do
    get :new, :url => "test/fixtures/files/mycom.rss1"
    assert_response :success
  end

  test "create" do
    login_as :taro
    post :create, :filter => {:title => "test create", :params_string => CGI.escape("url=test/fixtures/files/mycom.rss1")}
    assert_redirected_to root_path
    assert_equal "test create", assigns(:filter).title
  end

  test "create without login" do
    post :create, :filter => {:title => "test create", :params_string => CGI.escape("url=test/fixtures/files/mycom.rss1")}
    assert_response :forbidden
  end

  test "show" do
    get :show, :id => filters(:blog).id
    assert_response :success
  end

  test "update" do
    login_as :taro
    put :update, :id => filters(:blog).id, :filter => {:title => "test update"}
    assert_redirected_to root_path
    assert_equal "test update", assigns(:filter).title
  end

  test "update without identification" do
    login_as :jiro # not the author
    put :update, :id => filters(:blog).id, :filter => {:title => "test update"}
    assert_response :forbidden
  end

  test "destroy" do
    login_as :taro
    delete :destroy, :id => filters(:blog).id
    assert_redirected_to root_path
    assert_raise(ActiveRecord::RecordNotFound){ filters(:blog, :reload) }
  end

  test "destroy without identification" do
    login_as :jiro # not the author
    delete :destroy, :id => filters(:blog).id
    assert_response :forbidden
  end

  test "feed" do
    get :feed, :id => filters(:blog).id
    assert_response :success
  end

  test "feed with user_id" do
    assert_difference "filters(:blog).subscriptions.count(:conditions => {:user_id => users(:taro)})" do
      get :feed, :id => filters(:blog).id, :user_id => users(:taro).id
      assert_response :success
    end
  end
end
