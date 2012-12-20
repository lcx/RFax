class CreateMailHeaders < ActiveRecord::Migration
  def self.up
    create_table :mail_headers do |t|
      t.string :mail_header
      t.integer :user_id
      t.integer :did_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :mail_headers
  end
end
