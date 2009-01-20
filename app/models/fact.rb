class Fact < ActiveRecord::Base
	
	has_many :connections, :as => :object, :class_name => 'Polyco'
	has_many :connecteds, :as => :subject, :class_name => 'Polyco'
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Tag"

	has_many :objects, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	
	has_many :votes, :as => :rankable, :class_name => 'Ranking'
	has_many :parents, :through => :connecteds, :source => :object, :source_type => "Comment" 
	
	named_scope :gather_tags, :select => "T.name AS label, COUNT(DISTINCT TA.id) AS counted", :joins => ["LEFT OUTER JOIN taggings TA ON TA.taggable_id = facts.id AND TA.taggable_type = 'Fact' INNER JOIN tags T on T.id = TA.tag_id AND TA.tag_type = 'Tag'" ], :group => "T.id", :order => "T.name ASC"
	
	
	define_index do 
		indexes :body, :as => :body
		indexes [:body, tags(:name)], :as => :tags
		
		has objects(:id), :as => :nuniverse_ids
	end
	def category
		tags.first rescue nil
	end
	
	def body_with_tag
		return "#{self.category.name}: #{body}" if self.category
		body
	end
	
	def rank
		votes.count
	end
	
	
end
