# -*- coding: utf-8 -*-
require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  [
    ["mycom.rss1", 50, {"@rdf:about" => "column"}, 3],
    ["mycom.rss1", 50, {"@rdf:about" => "column", "!all" => "deny"}, 50 - 3],
    ["mycom.rss1", 50, {"@rdf:about" => "column, articles"}, 10],
    ["yakitara.rss2", 25, {"category" => "Rails"}, 9],
    ["yakitara.rss2", 25, {"category" => "Rails", "!all" => "deny"}, 25 - 9],
    ["yakitara.rss2", 25, {"category" => "Rails, Ruby"}, 11],
    ["yakitara.atom", 25, {"category@term" => "Rails"}, 9],
    ["yakitara.atom", 25, {"category@term" => "Rails", "!all" => "deny"}, 25 - 9],
    ["yakitara.atom", 25, {"category@term" => "Rails, Ruby"}, 11],
    ["kohmi.rss2", 20, {"title" => "明日"}, 4], # shuld much with numerical character references
    ["yakitara.atom", 25, {"category@term" => "rails"}, 9], # should much case-insensitive
  ].each do |file, before_count, filter_params, after_count|
    test "filter #{file} with #{filter_params}" do
      feed = Feed.parse(fixture_file_read(File.join("files",file)))
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

  [
    ["mycom.rss1", {
        :title => /^【レビュー】起動オプション/, 
        :content => /^「起動オプション」/, 
        :link => %r"^http://feeds.journal.mycom.co.jp/~r/haishin/rss/pc/~3/Yal9w1GBqW0/index.html"
      }],
    ["atnd.rss2", {
        :title => /^日本Android/,
        :content => /^<B>【注意】ご自身/, # content is cdata
        :link => %r"^http://atnd.org/events/1179"}],
    ["yakitara.atom", {
        :title => /^annotates where partial/,
        :content => /^Rails アプリケーション/,
        :link => %r"^http://blog.yakitara.com/2009/06/annotates-where-partial-code-come-from.html"}],
  ].each do |file, children|
    test "child_reader #{file} with #{children}" do
      feed = Feed.parse(fixture_file_read(File.join("files",file)))
      entry = feed.entries.first
      children.each do |name, regexp|
        assert_match regexp, entry.send(name)
      end
    end
  end

  # TODO: describe it using RSpec's mock
  # TODO: use partial mock against URI#open to raise Errno::ECONNREFUSED or other errors
#   test "handling connection refused" do
#   end
end
