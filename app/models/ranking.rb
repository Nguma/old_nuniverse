class Ranking < ActiveRecord::Base
	belongs_to :rankable, :polymorphic => true
	belongs_to :user
	
	named_scope :by_user, lambda {|user| 
		user.nil? ? {} : {:conditions => ["user_id in (?)", [*user].collect{|c| c.id}]}
	}
end
