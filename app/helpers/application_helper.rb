# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Overwrite original ActionView::Helpers::TranslationHelper#translate to pass through missing translations
  def translate(key, options={})
    I18n.translate(scope_key_by_partial(key), options.merge(:raise => true, :default => key))
#   rescue I18n::MissingTranslationData => e
#     key
  end
  alias :t :translate

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
    if commit = FeedKraft[:commit]
      "(" + link_to(commit[0...8], "http://github.com/hiroshi/feedkraft/commit/#{commit}") + ")"
    end
  end
end
