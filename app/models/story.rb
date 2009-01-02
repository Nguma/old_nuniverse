class Story < ActiveRecord::Base
	
	belongs_to :parent, :class_name => "Story"
	belongs_to :author, :class_name => "User"
	
	has_many :rankings, :as => :rankable, :dependent => :destroy

	has_many :connections, :as => :object, :class_name => 'Polyco'
	has_many :connecteds, :as => :subject, :class_name => 'Polyco'
	
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse", :conditions => ["state = 'active'"]
	# has_many :stories, :through => :connections, :source => :subject, :source_type => "Story", :dependent => :destroy
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :users, :through => :connecteds, :source => :object, :source_type => "User"
	
	has_many :pending_items, :through => :connections, :source => :subject, :source_type => "Tag", :conditions => ["state = 'pending' "], :dependent => :destroy
		
	acts_as_state_machine :initial => :pending
	
	state :pending
	state :activated
	state :object
	
	validates_presence_of :name
	
	define_index do
	  indexes name, :sortable => true	
		
	  has  created_at, updated_at
		
	end
	
	
	
	named_scope :created_by, lambda {|user|
		user.nil? ? {} : {:conditions => {:author_id => user.id}}
	}
	
	named_scope :without_parent, :conditions => {:parent_id => nil}
	
	named_scope :order_by_score, {
		:select => "stories.*, AVG(score) as average_score",
		:joins => ["LEFT OUTER JOIN rankings ON rankable_id = stories.id AND rankable_type = 'Story'"],
		:order => "average_score DESC",
		:group => "stories.id"
	}
	
	def score
		(self.rankings.average :score) || 0
	end
	
	def image
		images.first.public_filename
	end
end
