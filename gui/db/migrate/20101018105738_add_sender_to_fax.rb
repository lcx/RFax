class AddSenderToFax < ActiveRecord::Migration
  def self.up
    add_column :faxes, :sender, :string
  end

  def self.down
    remove_column :faxes, :sender
  end
end
