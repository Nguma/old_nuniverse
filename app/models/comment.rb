class Comment < ActiveRecord::Base
	
	before_create :create_tag
	
	def create_tag
		t = Tag.create (
			:label => self.body[0..255],
			:description => self.body
			:kind => self.kind
		)
		self.tag = t
	end
end
