class Comment < ActiveRecord::Base
	
	belongs_to :user, :class_name => 'User'

	belongs_to :tag, :class_name => "Tag"
	has_many :taggings, :as => :taggable
	
	before_create :create_tag
	
	attr_accessor :kind
	
	def create_tag
		t = Tag.create (
			:label => self.body[0..255],
			:description => self.body,
			:kind => 'comment'
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
	
		self.tag.connections_to.tagged('reply').collect {|c| c.subject.source}
	end
	

end
