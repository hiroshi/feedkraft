# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def has_content_for?(name)
    !instance_variable_get("@content_for_#{name}").nil?
  end

  # NOTE: sometimes text in a feed contains numerical character references, but escape nothing may be dangerous.
  # NOTE: So do ERB::Util#html_escape (aka h()) without escaping '&'
  FEED_TEXT_ESCAPE = ERB::Util::HTML_ESCAPE.except("&")
  def feed_text_escape(s)
    s.to_s.gsub(/["><]/) { |special| FEED_TEXT_ESCAPE[special] }
  end

  def commit
    if commit = Feedkraft[:commit]
      "(" + link_to(commit[0...8], "http://github.com/hiroshi/feedkraft/commit/#{commit}") + ")".html_safe
    end
  end
end
