class Comment < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable
	
	belongs_to :author, :class_name => 'User', :foreign_key => 'user_id'
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :replies, :through => :connections, :source => :subject, :source_type => "Comment"
	
	def name
		body
	end
	
	def tags
		taggings.collect {|c| c.predicate }
	end
end
