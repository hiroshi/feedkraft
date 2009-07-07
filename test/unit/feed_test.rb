require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  test "rss1 filter" do
    feed = Feed.parse(fixture_file_read("files/mycom.rss1"))
    assert_equal 50, feed.entries.size
    feed.filter!("@rdf:about" => "column")
    assert_equal 3, feed.entries.size
  end

  test "rss2 filter" do
    feed = Feed.parse(fixture_file_read("files/yakitara.rss2"))
    assert_equal 25, feed.entries.size
    feed.filter!(:category => "Rails")
    assert_equal 9, feed.entries.size
  end

  test "atom filter" do
    feed = Feed.parse(fixture_file_read("files/yakitara.atom"))
    assert_equal 25, feed.entries.size
    feed.filter!("category@term" => "Rails")
    assert_equal 9, feed.entries.size
  end
end
