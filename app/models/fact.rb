class Fact < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Tag"
	has_many :contexts, :through => :taggings, :source => :tag, :source_type => "Collection"
	has_many :bookmarks, :through => :connections, :source => :subject, :source_type => "Bookmark"
	has_many :connections, :as => :object, :class_name => 'Polyco'
	has_many :connecteds, :as => :subject, :class_name => 'Polyco'
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"

	has_many :objects, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	
	has_many :votes, :as => :rankable, :class_name => 'Ranking'
	has_many :parents, :through => :connecteds, :source => :object, :source_type => "Comment" 
	has_many :facts, :through => :connecteds, :source => :object, :source_type => "Fact"
	
	
	named_scope :gather_tags, :select => "T.name AS label, COUNT(DISTINCT TA.id) AS counted", :joins => ["LEFT OUTER JOIN taggings TA ON TA.taggable_id = facts.id AND TA.taggable_type = 'Fact' INNER JOIN tags T on T.id = TA.tag_id AND TA.tag_type = 'Tag'" ], :group => "T.id", :order => "T.name ASC"
	
	named_scope :tagged, lambda {|tag| 
		tag.nil? ? {} : {
		:select => "T.name ", :conditions => ["T.name rlike ?", tag.name], :joins => ["LEFT OUTER JOIN taggings TA ON TA.taggable_id = facts.id AND TA.taggable_type = 'Fact' INNER JOIN tags T on T.id = TA.tag_id AND TA.tag_type = 'Tag'" ]		
	}}
	named_scope :sphinx, lambda {|*args| {
    :conditions => { :id => search_for_ids(*args) }
  }}

	alias_attribute :name, :body
	
	define_index do 
		indexes :body, :as => :body
		indexes [:body, tags(:name)], :as => :tags
		
		has objects(:id), :as => :nuniverse_ids
	end
	

	
	def category
		body.scan(/^([\w\s\-\_]+)\:/)[0]
		# tags.first rescue nil
	end
	
	def body_without_category
		body.gsub(/^([\w\s\-\_]+\:\s?)/, '')
	end
	
	def body_with_tag
		return "#{self.category.name}: #{body}" if self.category
		body
	end
	
	def rank
		votes.count
	end
	
	
end
