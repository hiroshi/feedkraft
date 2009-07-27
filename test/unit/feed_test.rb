require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  [
    ["files/mycom.rss1", 50, {"@rdf:about" => "column"}, 3],
    ["files/mycom.rss1", 50, {"@rdf:about" => "column", "!all" => "deny"}, 50 - 3],
    ["files/mycom.rss1", 50, {"@rdf:about" => "column, articles"}, 10],
    ["files/yakitara.rss2", 25, {"category" => "Rails"}, 9],
    ["files/yakitara.rss2", 25, {"category" => "Rails", "!all" => "deny"}, 25 - 9],
    ["files/yakitara.rss2", 25, {"category" => "Rails, Ruby"}, 11],
    ["files/yakitara.atom", 25, {"category@term" => "Rails"}, 9],
    ["files/yakitara.atom", 25, {"category@term" => "Rails", "!all" => "deny"}, 25 - 9],
    ["files/yakitara.atom", 25, {"category@term" => "Rails, Ruby"}, 11],
    ["files/kohmi.rss2", 20, {"title" => "明日"}, 4],
  ].each do |path, before_count, filter_params, after_count|
    test "filter #{path} with #{filter_params}" do
      feed = Feed.parse(fixture_file_read(path))
      assert_equal before_count, feed.entries.size
      feed.filter!(filter_params)
      assert_equal after_count, feed.entries.size
    end
  end

  test "split_value" do
    {
      '' => [""],
      'foo' => ["foo"],
      'foo, bar' => ["foo", "bar"],
      'foo, "bar"' => ["foo", "bar"],
      'foo, "bar "' => ["foo", "bar "],
      'foo, "bar" ' => ["foo", "bar"],
      'foo, "  ", baz ' => ["foo", "  ", "baz"],
      'foo, "bar, baz"' => ["foo", "bar, baz"],
      "foo, 'bar, baz'" => ["foo", "bar, baz"],
      'foo, "bar, baz", 日本語' => ["foo", "bar, baz", "日本語"],
    }.each do |string, array|
      assert_equal array, Feed.split_value(string)
    end
  end
end
