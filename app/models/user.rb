class User < ActiveRecord::Base
  has_many :filters
  has_many :subscriptions

  validates_uniqueness_of :name, :allow_nil => true
end
