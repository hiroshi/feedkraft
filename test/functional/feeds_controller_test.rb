require 'test_helper'

class FeedsControllerTest < ActionController::TestCase
  test "index" do
    get :index, :src => "http://feeds.journal.mycom.co.jp/haishin/rss/pc?format=xml"
  end
end
