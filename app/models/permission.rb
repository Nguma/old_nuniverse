class Permission < ActiveRecord::Base
	belongs_to :user, :class_name => "User"
	belongs_to :list, :class_name => "List", :foreign_key => 'tagging_id'
	
	validates_presence_of :tagging_id, :user_id
	
	validates_uniqueness_of :user_id, :scope => :tagging_id
	
	named_scope :for, lambda {|list| 
		list.nil? ? {} : {:conditions => ['tagging_id = ?',list.id]}
	}
	
	def path
		tagging.path
	end
	
end
