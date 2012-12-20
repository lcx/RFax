class CreateDids < ActiveRecord::Migration
  def self.up
    create_table :dids do |t|
      t.integer :user_id
      t.string :did
      t.integer :service_type_id
      t.string :state
      t.timestamps
    end
  end
  
  def self.down
    drop_table :dids
  end
end
