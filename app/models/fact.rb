class Fact < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Nuniverse"
	has_many :contexts, :through => :taggings, :source => :tag, :source_type => "Collection"
	has_many :bookmarks, :through => :connections, :source => :subject, :source_type => "Bookmark"
	has_many :connections, :as => :object, :class_name => 'Polyco'
	has_many :connecteds, :as => :subject, :class_name => 'Polyco'
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	has_many :comments, :through => :connections, :source => :subject, :source_type => "Commment"

	has_many :objects, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	
	has_many :votes, :as => :rankable, :class_name => 'Ranking'
	has_many :pros, :as => :rankable, :class_name => 'Ranking', :conditions => "score = 1"
	has_many :cons, :as => :rankable, :class_name => 'Ranking', :conditions => "score = 0"
	# has_many :parents, :through => :connecteds, :source => :object, :source_type => "Nuniverse" 
	has_many :facts, :through => :connections, :source => :subject, :source_type => "Fact"
	
	belongs_to :parent, :polymorphic => :true
	belongs_to :author, :class_name => "User"
	
	
	named_scope :gather_tags, :select => "T.name AS label, COUNT(DISTINCT TA.id) AS counted", :joins => ["LEFT OUTER JOIN taggings TA ON TA.taggable_id = facts.id AND TA.taggable_type = 'Fact' INNER JOIN nuniverses T on T.id = TA.tag_id AND TA.tag_type = 'Nuniverse'" ], :group => "T.id", :order => "T.name ASC"
	
	named_scope :tagged, lambda {|tag| 
		tag.nil? ? {} : {
		:select => "T.name ", :conditions => ["T.name rlike ?", tag.name], :joins => ["LEFT OUTER JOIN taggings TA ON TA.taggable_id = facts.id AND TA.taggable_type = 'Fact' INNER JOIN tags T on T.id = TA.tag_id AND TA.tag_type = 'Tag'" ]		
	}}
	
	named_scope :tagged, lambda {|tag| 
		tag.nil? ? {} : {
		 :conditions => ["body rlike ?", "^#{tag.name}:"]	
	}}
	
	named_scope :sphinx, lambda {|*args| {
    :conditions => { :id => search_for_ids(*args) }
  }}

	alias_attribute :name, :body
	
	# define_index do 
	# 		indexes [:body,  tags(:name)], :as => :body
	# 		indexes author.login, :as => :author
	# 		indexes [tags(:name)], :as => :tags
	# 		indexes [parent.unique_name], :as => :parent
	# 		indexes [:parent_type], :as => :parent_type
	# 		
	# 		has :parent_id, :created_at
	# 		has objects(:id), :as => :nuniverse_ids
	# 		has tags(:id), :as => :tag_ids
	# 		set_property :delta => :true
	# 		
	# 		# has parent(:id), :as => :parent
	# 	end
	
	def unique_name
		body.gsub(/[^a-z0-9\_\s]+/i, '').gsub(' ','_').downcase
	end
	
	def category
		tags.first.name rescue nil
		# tags.first rescue nil
	end
	
	def body_without_category
		body.gsub(/^\/?[\w\s]+\s?\:\s/, '')
	end
	
	def body_with_tag
		return "#{self.category.name}: #{body}" if self.category
		body
	end
	
	def rank
		votes.count
	end
	
	def is_a_join?
		return true if tokens.length == 1
		return false
	end
	
	
	def tokens
		tokens = []
		self.body.scan(/\#([\w\_]+)/).flatten.reject {|t| t.blank?}.each do |t|
			tokens << Nuniverse.find_by_unique_name(t)
		end
		tokens
	end
	
	def percent_of_pros
		((pros.size * 100)/votes.size).round
	end
	
	def percent_of_cons
		((cons.size * 100)/votes.size).round
	end
	
	def build_path
		path = "/#{unique_name}"
	end
	
end
