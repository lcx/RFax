class AddMailSenderToMailHeader < ActiveRecord::Migration
  def self.up
    add_column :mail_headers, :mail_sender, :string
  end

  def self.down
    remove_column :mail_headers, :mail_sender
  end
end
