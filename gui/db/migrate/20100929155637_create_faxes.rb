class CreateFaxes < ActiveRecord::Migration
  def self.up
    create_table :faxes do |t|
      t.string :state
      t.string :dest
      t.string :localstationid
      t.string :localheaderinfo
      t.string :faxstatus
      t.string :faxerror
      t.string :remotestationid
      t.integer :faxpages
      t.integer :faxbitrate
      t.string :faxresolution
      t.integer :tries
      t.integer :user_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :faxes
  end
end
