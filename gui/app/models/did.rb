class Did < ActiveRecord::Base
  attr_accessible :user_id, :did, :service_type_id, :state
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :service_type
  has_many :mail_headers
end
