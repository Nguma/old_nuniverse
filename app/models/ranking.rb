class Ranking < ActiveRecord::Base
	belongs_to :rankable, :polymorphic => true
	belongs_to :user, :class_name => 'User'
	
	
	named_scope :by, lambda {|user| 
		user.nil? ? {} : {:conditions => ["user_id in (?)", [*user].collect{|c| c.id}]}
	}
	
	named_scope :about, lambda {|rankable| 
		rankable.nil? ? {} : {:conditions => ["rankable_id = ? AND rankable_type = ?", rankable.id, rankable.class.to_s]}
	}
	
	
	define_index do
		indexes rankable.name, :as => :rankable
		set_property :delta => true
	end
	
	
	def review
		Comment.find(:last, :conditions => {:parent_id => rankable_id, :parent_type => rankable_type, :user_id => user_id})
	end
	
	
	def self.find_or_create(params)
	
		r = Ranking.find(:first, :conditions => {:user_id => params[:user_id], :rankable_type => params[:rankable_type], :rankable_id => params[:rankable_id]})
	
		if r.nil?
			r = Ranking.create(params) 
		else
		
			r.score = params[:score]
			r.save
		end
		r
	end
	

	
	def color 
		Ranking.color(score-1)
	end
	
	
	def label 
		Ranking.label(score)
	end
	
	protected
	
	def self.color(score)
		['#FF0000','#FF9900','#dddd00','#99FF00','#00FF00'][(score).floor]
	end
	
	def self.label(score) 
		['Despicable','Miserable','Regretable','Forgetable','Plain','Okay','Likeable','Remarkable','Memorable','Iconic'][(score + 4).floor]
	end
	
	
	

end
