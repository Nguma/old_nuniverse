class List < ActiveRecord::Base

	belongs_to :tag, :class_name => 'Tag'
	belongs_to :creator, :class_name => 'User'
	after_create :create_tag
	
	def items
		Tagging.find(:all, :conditions => ['subject_id = ?', self.tag.id])
	end
	
	protected
	def create_tag
		self.tag = Tag.create(
			:label => self.label,
			:kind => 'list'
		)
		self.save
	end
	
end
