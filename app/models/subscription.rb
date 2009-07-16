class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :filter

  private

  before_create :set_key
  def set_key
    self.key = Digest::SHA1.hexdigest("#{self.user_id} - #{self.filter_id}")[0...8]
    while self.class.count(:conditions => {:key => key}) > 0 # in case of confliction
      self.key = Digest::SHA1.hexdigest(self.key)[0...8]  
    end
  end
end
