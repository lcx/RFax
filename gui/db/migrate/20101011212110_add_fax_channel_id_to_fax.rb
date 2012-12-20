class AddFaxChannelIdToFax < ActiveRecord::Migration
  def self.up
    add_column :faxes, :fax_channel_id, :integer
  end

  def self.down
    remove_column :faxes, :fax_channel_id
  end
end
