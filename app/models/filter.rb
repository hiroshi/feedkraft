class Filter < ActiveRecord::Base
  # TODO: the class name Fileter conflicts in name space of ActionController. Change to an unique name

  belongs_to :user

  def params
    @params ||= CGI.parse(self.params_string).inject({}){|h,pair| h.update(pair.first.to_sym => pair.last.first) }
  end

  before_save :set_sha1
  def set_sha1
    require "digest/sha1"
    self.sha1 = Digest::SHA1.hexdigest(self.params_string)
  end
end
