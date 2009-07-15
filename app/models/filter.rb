class Filter < ActiveRecord::Base
  # TODO: the class name Fileter conflicts in name space of ActionController. Change to an unique name

  belongs_to :user
  has_many :subscriptions

  def params
    if self.params_string
      @params ||= CGI.parse(CGI.unescape(self.params_string)).inject({}){|h,pair| h.update(pair.first => pair.last.join(",")) }.with_indifferent_access
    else
      {}
    end
  end

  before_save :set_sha1
  def set_sha1
    require "digest/sha1"
    self.sha1 = Digest::SHA1.hexdigest(self.params_string)
  end

  # == named scopes
  named_scope :latest, lambda {
    {:include => :user, :order => "filters.created_at DESC"}
  }
  # NOTE: those nasty named scopes below are just for smaller number of queries
  named_scope :with_subscription_key_for, lambda{|user|
    if user
      {
        :select => "filters.*, s.key AS subscription_key",
        :joins => "LEFT JOIN subscriptions AS s ON s.filter_id = filters.id AND s.user_id = #{user.id}"
      }
    else
      {}
    end
  }

  named_scope :popular, lambda {|*args|
    options = args.extract_options!
    result = {
      :select => "filters.*, COUNT(subscriptions.id) AS subscription_count",
      #:joins => [:subscriptions],
      :joins => "INNER JOIN subscriptions ON subscriptions.filter_id = filters.id",
      :include => :user,
      :conditions => ["subscriptions.accessed_at > ?", 1.day.ago],
      # NOTE: PostgreSQL requires all column name specified in select with COUNT a columns of joined table
      # TODO: hide this implementation dependent code...
      :group => column_names.map{|n| "filters.#{n}"}.join(", "),
      :order => "subscription_count DESC"
    }
    if user = options[:with_subscription_key_for]
      result[:select] += ", s.key AS subscription_key"
      result[:joins] += " LEFT JOIN subscriptions AS s ON s.filter_id = filters.id AND s.user_id = #{user.id}"
      result[:group] += ", s.key"
    end
    result
  }
end
