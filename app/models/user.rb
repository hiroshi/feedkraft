class User < ActiveRecord::Base
  has_many :filters

  validates_uniqueness_of :name
end
