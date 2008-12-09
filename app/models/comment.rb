class Comment < ActiveRecord::Base
	
	belongs_to :user, :class_name => 'User'

	has_one :tag, :as => :taggable
	has_many :taggings, :as => :taggable
	
	before_create :create_tag
	
	attr_accessor :kind
	
	def create_tag
		t = Tag.create (
			:label => self.body[0..255],
			:description => self.body,
			:kind => 'note'
		)
		self.tag = t
		
	end
	
	def tag_with(tags)
		tags.to_a.each do |t|
			@t = Tagging.create(:predicate => t, :taggable => self) rescue nil
		end
		return @t
	end
	
	def replies
		self.tag.connections_from.tagged('reply')
	end
	

end
