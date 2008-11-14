class Group < ActiveRecord::Base
	belongs_to :user
	belongs_to :tag
	
	before_create :create_tag
	
	
	def create_tag
		t = Tag.create (
			:label => self.name,
			:kind => 'group'
		)
		self.tag = t
	end
	
end