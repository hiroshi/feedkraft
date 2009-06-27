class User < ActiveRecord::Base
  has_many :filters
end
