# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def has_content_for?(name)
    !instance_variable_get("@content_for_#{name}").nil?
  end
end
