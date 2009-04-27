class Comment < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings

	has_many :bookmarks, :through => :connections, :source => :subject, :source_type => "Bookmark"
	has_many :connections, :as => :object, :class_name => 'Polyco'
	has_many :connecteds, :as => :subject, :class_name => 'Polyco'
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	has_many :comments, :through => :connections, :source => :subject, :source_type => "Commment"

	has_many :objects, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	
	has_many :rankings, :as => :rankable, :class_name => 'Ranking'
	has_many :facts, :through => :connections, :source => :subject, :source_type => "Fact"
	
	belongs_to :parent, :polymorphic => :true
	belongs_to :author, :class_name => "User", :foreign_key => 'user_id'

	
	
	define_index do 
		indexes [:body], :as => :body
		
		has :user_id
		has :created_at
		has tags(:id), :as => :tag_ids
		
		set_property :delta => true
	end
	
	
	def matching_vote
		Ranking.by(author).about(parent).first
	end
	
	

end
