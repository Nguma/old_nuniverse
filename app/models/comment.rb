class Comment < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable
	
	belongs_to :author, :class_name => 'User', :foreign_key => 'user_id'
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"

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
end
