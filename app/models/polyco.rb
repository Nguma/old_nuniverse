class Polyco < ActiveRecord::Base
	belongs_to :subject, :polymorphic => true
	belongs_to :object, :polymorphic => true
	
	has_many :rankings, :as => :rankable
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings

	has_many :rankings, :as => :rankable, :class_name => 'Ranking', :dependent => :destroy
	
	has_many :connections, :as => :object, :class_name => "Polyco"
	
	before_save :update_state
	after_create :update_state
	
	acts_as_state_machine :initial => :pending

  state :pending
	state :active

  event :make_active do
   transitions :to => :active, :from => :pending
  end
	
	define_index do 
		
		indexes [subject.unique_name, subject.login, subject.body, object.unique_name, object.login], :as => :content, :sortable => true
		# indexes [tags(:name), subject.tags(:name),  subject_type], :as => :tags
		indexes subject_type, :as => :subject_type
		
		
		has "object_type = 'User'", :as => :from_user, :type => :boolean 
		has "subject_type = 'Nuniverse'", :as => :to_nuniverse, :type => :boolean
		
		has [tags(:id), subject.tags(:id)], :as => :tag_ids
		has :suggestable => 0
		has :object_id
		has :subject_id
		has :created_at
		
		set_property :delta => true
	end
	
	named_scope :sphinx, lambda {|*args| {
    :conditions => { :id => search_for_ids(*args) }
  }}
  
	
	named_scope :order_by_date, :order => "created_at DESC"
	
	named_scope :order_by_name, :order => "name DESC"
	
	named_scope :order_by_score, :order => "average_score DESC"
	

	
	named_scope :tagged, lambda { |tag| 
		tag.blank? ? {} : { :conditions => ["tag_id = ?",tag.id ], :joins => "LEFT OUTER JOIN taggings ON (taggable_id = polycos.id AND taggable_type = 'Polyco') OR (taggable_id = polycos.subject_id AND taggable_type = polycos.subject_type) LEFT OUTER JOIN tags on taggings.tag_id = tags.id "}
	}
	
	named_scope :with_score, lambda { |user| 
		user.nil? ? {
			:select => "polycos.*, AVG(score) as average_score, SUM(score) as total_score",
			:joins => ["LEFT OUTER JOIN rankings ON rankable_id = polycos.subject_id AND rankable_type = 'Nuniverse'"],
			:group => "polycos.id" 		
		} : {
			:select => "polycos.*, AVG(score) as average_score, SUM(score) as total_score",
			:joins => ["LEFT OUTER JOIN rankings ON rankable_id = polycos.subject_id AND rankable_type = 'Nuniverse' AND rankings.user_id in (#{[*user]}) "],
			:group => "polycos.id"
		}
	}
	
	named_scope :with_score_lower_than, lambda { |score| 
		score.nil? ? {} : {
			:select => "polycos.*, AVG(rankings.score) as score",
			:joins => ["LEFT OUTER JOIN rankings ON rankable_id = polycos.subject_id AND rankable_type = 'Nuniverse'"],
			:conditions => ["score < #{score}"],
			:group => "polycos.id"
		}
	}
	
	
	named_scope :with_score_higher_than, lambda { |score| 
		score.nil? ? {} : {
			:select => "polycos.*, AVG(rankings.score) as score",
			:joins => ["LEFT OUTER JOIN rankings ON rankable_id = polycos.subject_id AND rankable_type = 'Nuniverse'"],
			:conditions => ["score > #{score}"],
			:group => "polycos.id"
		}
	}
	
 	named_scope :of_klass, lambda { |klass| 
		klass.nil? ? {} : {:conditions => ['polycos.subject_type in (?)', [*klass]]}
	}
	
	named_scope :with_object, lambda {|object|
		object.nil? ? {} : {:conditions => {:object_id => object.id, :object_type => object.class.to_s}}
	}
	
	named_scope :with_subject, lambda {|subject|
		subject.nil? ? {} : {:conditions => {:subject_id => subject.id, :subject_type => subject.class.to_s}}
	}
	

	named_scope :gather_tags, :select => "polycos.*, T.name AS tag_name, T.id as tag_id, COUNT(DISTINCT TA.id) AS counted", :joins => ["LEFT OUTER JOIN taggings TA ON TA.taggable_id = polycos.id AND TA.taggable_type = 'Polyco' INNER JOIN tags T on T.id = TA.tag_id " ], :group => "T.id", :order => "tag_name ASC"

	named_scope :related_connections, lambda {|object|
		object.nil? ? {} : { :joins => ["LEFT OUTER JOIN polycos P ON (P.subject_id = polycos.object_id AND P.subject_type = polycos.object_type AND P.object_id = #{object.id} AND P.object_type = '#{object.type}')" ], :conditions => ["P.id IS NOT NULL"]}
		}  
		

		
	def category
		tags.first
	end
	
	def score
			(rankings.average(:score)) rescue 0
	end

	def self.find_or_create(params)
		params[:description] ||= nil
		Polyco.with_subject(params[:subject]).with_object(params[:object]).first || Polyco.create(:subject_id => params[:subject].id,:subject_type =>params[:subject].class.to_s, :object_id =>params[:object].id ,:object_type =>  params[:object].class.to_s, :description => params[:description])
	end
	
	
	

	protected
	
	def update_state
		self.make_active! #unless !subject.active
	end
end