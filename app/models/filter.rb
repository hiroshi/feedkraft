class Filter < ActiveRecord::Base
  belongs_to :user

  before_save :set_sha1
  def set_sha1
    require "digest/sha1"
    self.sha1 = Digest::SHA1.hexdigest(self.params_string)
  end
end
