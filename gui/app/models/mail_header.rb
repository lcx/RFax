class MailHeader < ActiveRecord::Base
  attr_accessible :mail_header, :user_id, :did_id,:mail_sender
  belongs_to :did
  belongs_to :user
end
