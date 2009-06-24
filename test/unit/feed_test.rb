require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  test "filter" do
    feed = Feed.parse(fixture_file_read("files/mycom.rss1"))
    assert_equal 50, feed.entries.size
    feed.filter!(:identifier => "column")
    assert_equal 3, feed.entries.size
  end
end
