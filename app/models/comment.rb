class Comment < ActiveRecord::Base
	
	has_many :taggings, :as => :taggable
	
	belongs_to :author, :class_name => 'User', :foreign_key => 'user_id'
	belongs_to :parent, :polymorphic => true
	

end
