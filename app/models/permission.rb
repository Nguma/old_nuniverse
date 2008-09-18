class Permission < ActiveRecord::Base
	belongs_to :grantor, :class_name => "User", :foreign_key => :grantor_id
	belongs_to :granted, :class_name => "User"
	
	validates_presence_of :grantor_id, :granted_id, :tags
	
end
