class Polyco < ActiveRecord::Base
	belongs_to :subject, :polymorphic => true
	belongs_to :object, :polymorphic => true
	
	has_many :rankings, :as => :rankable
	
	has_many :taggings, :as => :taggable
	
	

	
	define_index do 
		indexes [subject.name, subject.taggings.predicate, taggings.predicate], :as => :name, :sortable => true
		indexes subject_type, :as => :type
		
		set_property :delta => true
		
	end
	
	named_scope :sphinx, lambda {|*args| {
    :conditions => { :id => search_for_ids(*args) }
  }}
  
	
	named_scope :order_by_date, :order => "created_at DESC"
	
	named_scope :order_by_name, :order => "name DESC"
	
	named_scope :order_by_score, :order => "average_score DESC"
	
	named_scope :tagged, lambda { |tag| 
		tag.nil? ? {} : { :conditions => ["taggings.predicate rlike ?",tag ], :joins => "LEFT OUTER JOIN taggings ON (taggable_id = polycos.id AND taggable_type = 'Polyco') OR (taggable_id = polycos.subject_id AND taggable_type = polycos.subject_type) "}
	}
	
	named_scope :with_score, lambda { |user| 
		user.nil? ? {
			:select => "polycos.*, AVG(score) as average_score",
			:joins => ["LEFT OUTER JOIN rankings ON rankable_id = polycos.id AND rankable_type = 'Polyco'"],
			:group => "polycos.id" 		
		} :
		{
			:select => "polycos.*, AVG(score) as average_score",
			:joins => ["LEFT OUTER JOIN rankings ON rankable_id = polycos.id AND rankable_type = 'Polyco' AND rankings.user_id in (#{[*user]}) "],
			:group => "polycos.id"
		}
	}
	
 	named_scope :of_klass, lambda { |klass| 
		klass.nil? ? {} : {:conditions => ['polycos.subject_type in (?)', [*klass]]}
	}
	
	named_scope :with_object, lambda {|object|
		object.nil? ? {} : {:conditions => {:object => object.id, :object_type => object.class.to_s}}
	}
	
	named_scope :with_subject, lambda {|subject|
		subject.nil? ? {} : {:conditions => {:subject_id => subject.id, :subject_type => subject.class.to_s}}
	}
	
	named_scope :exclude_twins, {:conditions => "state != 'twin'"}

	
	def score
		average_score.to_i || 0
	end
	
	def twin
		self.subject.connections.with_subject(self.object).first || Polyco.new(:subject => self.object, :object => self.subject, :name => self.object.name, :description => self.description, :state => "twin")
	end
	
	def tags
		taggings.collect {|c| c.predicate}
	end
	

	
	def save_all
		twin.save if self.state != "pending"
		self.save
	end
end