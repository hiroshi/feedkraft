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
  named_scope :latest, lambda{|*args|
    options = args.extract_options!
    {:include => :user, :order => "created_at DESC"}.merge(options || {})
  }

  named_scope :popular, lambda {|*args|
    options = args.extract_options!
    {
      :select => "filters.*, COUNT(subscriptions.id) AS subscription_count",
      :joins => :subscriptions,
      :include => :user,
      :conditions => ["subscriptions.updated_at > ?", 1.day.ago],
      # NOTE: PostgreSQL requires all column name specified in select with COUNT a columns of joined table
      # TODO: hide this implementation dependent code...
      :group => column_names.map{|n| "filters.#{n}"}.join(", "),
    }.merge(options || {})
  }
end
