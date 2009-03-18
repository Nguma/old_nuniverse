class Ranking < ActiveRecord::Base
	belongs_to :rankable, :polymorphic => true
	belongs_to :user, :class_name => 'User'
	
	named_scope :by, lambda {|user| 
		user.nil? ? {} : {:conditions => ["user_id in (?)", [*user].collect{|c| c.id}]}
	}
	

	
	def self.valuations
		{
			'love' => 5,
			'like' => 4,
			'neutrality' => 3,
			'dislike' => 2,
			'hate' => 1
		}
	end
	
	
	def label
		Ranking.valuations.index(score)
	end
	
	def self.find_or_create(params)
		r = Ranking.find(:first, :conditions => params)
	
		if r.nil?
			r = Ranking.create(params) 
		else
			
			r.score = params[:score]
			r.save
		end
		r
	end

end
