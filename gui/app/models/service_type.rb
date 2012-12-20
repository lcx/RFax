class ServiceType < ActiveRecord::Base
  attr_accessible :type_no, :name
  belongs_to :did, :class_name => "Did", :foreign_key => "did_id"
end
