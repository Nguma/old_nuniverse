class Fact < ActiveRecord::Base
	
	has_many :connections, :as => :object, :class_name => 'Polyco'
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Tag"
	
	named_scope :gather_tags, :select => "T.name AS label, COUNT(DISTINCT TA.id) AS counted", :joins => ["LEFT OUTER JOIN taggings TA ON TA.taggable_id = facts.id AND TA.taggable_type = 'Fact' INNER JOIN tags T on T.id = TA.tag_id AND TA.tag_type = 'Tag'" ], :group => "T.id", :order => "T.name ASC"
	
	
	def category
		tags.first rescue nil
	end
	
	def body_with_tag
		"#{self.category.name}: #{body}" rescue body
	end
end
