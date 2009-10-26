# visit = lambda{|page_name| Given "I am on #{page_name}" }

# Given(/^"([^\"]*)"ページを表示している$/, &visit)

# Given /^I am on (.+)$/ do |page_name|
#   visit path_to(page_name)
# end

# Then /^I press "([^\"]*)"$/ do |button|
#   find_button(button).should_not
# end
Given /^"([^\"]*)"ページをパラメータ"([^\"]*)"で表示している$/ do |page_name, params|
  data = params.split("&").inject({}){|h,param| pair = param.split("="); h.update(pair[0] => pair[1])}
  visit path_to(page_name), :get, data
end

Then /^"([^\"]*)"ボタンは存在しないこと$/ do |button|
  lambda {
    webrat.current_scope.find_button(button)
  }.should raise_error(Webrat::NotFoundError)
end
