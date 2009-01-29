class Comment < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable
	
	belongs_to :author, :class_name => 'User', :foreign_key => 'user_id'
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	
	has_many :options, :through => :connections, :source => :subject, :source_type => "Fact"
	has_many :comments, :as => :parent, :dependent => :destroy
	
	belongs_to :parent, :polymorphic => true
	
	define_index do
		indexes :body, :as => :body
	end
	
	def name
		body
	end
	
	def tags
		taggings.collect {|c| c.predicate }
	end
	
	def vote_count
		options.to_a.sum {|o| o.rank}
	end
	
	def is_wrapper?
		return true	if subjects.length == 1 && body == "\[\[#{subjects.first.name}\]\]"
		return false
	end
end
