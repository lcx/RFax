# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111203134255) do

  create_table "dids", :force => true do |t|
    t.integer  "user_id"
    t.string   "did"
    t.integer  "service_type_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fax_channels", :force => true do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faxes", :force => true do |t|
    t.string   "state"
    t.string   "dest"
    t.string   "localstationid"
    t.string   "localheaderinfo"
    t.string   "faxstatus"
    t.string   "faxerror"
    t.string   "remotestationid"
    t.integer  "faxpages"
    t.integer  "faxbitrate"
    t.string   "faxresolution"
    t.integer  "tries"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "fax_channel_id"
    t.string   "sender"
  end

  create_table "mail_headers", :force => true do |t|
    t.string   "mail_header"
    t.integer  "user_id"
    t.integer  "did_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mail_sender"
    t.string   "mail_domain"
  end

  create_table "rude_queues", :force => true do |t|
    t.string   "queue_name"
    t.text     "data"
    t.boolean  "processed",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rude_queues", ["processed"], :name => "index_rude_queues_on_processed"
  add_index "rude_queues", ["queue_name", "processed"], :name => "index_rude_queues_on_queue_name_and_processed"

  create_table "service_types", :force => true do |t|
    t.integer  "type_no"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
