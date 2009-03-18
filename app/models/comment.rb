class Comment < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Tag"
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
	belongs_to :author, :class_name => "User", :foreign_key => 'user_id'
	

end
