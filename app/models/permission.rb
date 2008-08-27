class Permission < ActiveRecord::Base
	belongs_to :user, :class_name => "User"
	belongs_to :tagging, :class_name => "Tagging"
	
	def path
		tagging.path
	end
	
end
