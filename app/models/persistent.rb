class Persistent < ActiveRecord::Base
  class << self
    def [](key)
      self.first(:select => "value", :conditions => {:key => key.to_s}).value
    end
  end
end
