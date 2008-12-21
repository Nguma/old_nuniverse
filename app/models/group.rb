class Group < ActiveRecord::Base
	belongs_to :user
	belongs_to :tag, :dependent => :destroy
	before_create :create_tag
	
	
	def create_tag
		t = Tag.create(
			:label => self.name,
			:kind => 'group'
		)
		self.tag = t
	end
	
	def privacy 
		self.private ? "private" : "public"
	end
	
	
	def members
		Connection.with_subject(self.tag).with_kind('user').tagged(['member','founder'])
	end
	
	def founder
		Connection.with_subject(self.tag).with_kind('user').tagged('founder')
	end

end