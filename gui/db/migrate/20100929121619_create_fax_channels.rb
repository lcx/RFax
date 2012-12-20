class CreateFaxChannels < ActiveRecord::Migration
  def self.up
    create_table :fax_channels do |t|
      t.string :state
      t.timestamps
    end
  end
  
  def self.down
    drop_table :fax_channels
  end
end
