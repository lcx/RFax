class User < ActiveRecord::Base
  attr_accessible :username, :email, :password
  has_many :dids, :class_name => "did", :foreign_key => "user_id"
  has_many :mail_headers
end
