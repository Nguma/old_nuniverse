class Connection < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	
	has_many :favorites, :foreign_key => "connection_id"
	# belongs_to :user, :class_name => "Tag"
	
	has_many :taggings, :as => :taggable
	has_many :rankings, :as => :rankable
	
		
	before_destroy :destroy_taggings
	
	named_scope :with_subject, lambda { |subject|
    subject.nil? ? {} :  {:conditions => ["connections.subject_id in (?)", [*subject].collect {|c| c.is_a?(Tag) ? c.id : c}] } 

  }
  named_scope :with_object, lambda { |object|
    object.nil? ? {} : {:conditions => ["connections.object_id in (?)", [*object].collect {|c| c.is_a?(Tag) ? c.id : c}]}

  }


	named_scope :tagged, lambda { |query| 
		query.nil? ? {} : {
			:select => "connections.*",
			:conditions => ["taggings.predicate rlike ?", query.to_a.join('|')], 
			:joins => "LEFT OUTER JOIN taggings ON (taggings.taggable_id = connections.id AND taggings.taggable_type = 'Connection') OR (taggings.taggable_id = connections.subject_id AND taggings.taggable_type = 'Tag')",
			:group => "connections.subject_id HAVING count(connections.subject_id) >= #{query.to_a.length}"
		}
	}
	
	named_scope :tagged_or_named, lambda { |q| 
		q.nil? ? {} : {
			:conditions => ['taggings.predicate rlike ? OR S.label rlike ?', q.to_a.join('|'), q.to_a.join('|')],
			:joins => ["LEFT OUTER JOIN taggings ON (taggings.taggable_id = connections.id AND taggings.taggable_type = 'Connection') OR (taggings.taggable_id = connections.subject_id AND taggings.taggable_type = 'Tag')"],
			:group => "connections.subject_id HAVING count(connections.subject_id) >= #{q.to_a.length}"
		}
	}
	
	named_scope :named, lambda { |name| 
		name.nil? ? {} : {
			:conditions => ["O.label rlike ?", "^#{name}"],
			:joins => "INNER JOIN tags O on O.id = connections.subject_id"
		}
	}

	named_scope :with_subject_kind, lambda { |kind| 
		kind.nil? ? {:joins => ["LEFT OUTER JOIN tags S on S.id = connections.subject_id "]} : {

			:conditions => ["S.kind = ?", kind],
			:joins => ["LEFT OUTER JOIN tags S on S.id = connections.subject_id "]
		}
	}
	
	named_scope :with_object_kind, lambda { |kind| 
		kind.nil? ? {} : {:conditions => ["O.kind = ?", kind], 
			:joins => "LEFT OUTER JOIN tags O ON connections.object_id = O.id "
			}
	}
	named_scope :by_kind, :group => "predicate", :select => ["connections.*, count(distinct subject_id) AS counted"], :joins => "LEFT OUTER JOIN taggings ON taggings.connection_id = connections.id "
	named_scope :distinct, :group => "connections.subject_id", :select => ["connections.*, count(distinct subject_id) AS counted"]
	
	named_scope :with_user_list, :group => "connections.subject_id", :joins => "LEFT OUTER JOIN favorites on favorites.connection_id = connections.id", :select => ["connections.*, GROUP_CONCAT(favorites.user_id SEPARATOR ',') AS users"]
	named_scope :gather, :select => " *, count(DISTINCT subject_id) AS counted",  :group => "taggings.predicate", :joins => "LEFT OUTER JOIN taggings ON taggings.connection_id = connections.id LEFT OUTER JOIN favorites ON favorites.connection_id = connections.id"
	
	named_scope :gather_tags, :select => "taggings.predicate, count(DISTINCT subject_id) AS counted",  :group => "taggings.predicate", :joins => " LEFT OUTER JOIN taggings ON (taggings.taggable_id = connections.subject_id AND taggings.taggable_type = 'Tag') OR (taggings.taggable_type = 'Connection' AND taggings.taggable_id = connections.id)"

	
	named_scope :order_by, lambda { |order| 
		order.nil? ? {} : {:select => ["connections.*, SUM(rankings.score) AS score"], :order => Connection.normalize_order(order), :joins => ["LEFT OUTER JOIN rankings ON rankings.rankable_id = connections.id  AND rankings.rankable_type = 'Connection'"], :group => "connections.id"}
	}
	
	def self.find_or_create(params)
		c = Connection.with_subject(params[:subject]).with_object(params[:object]).first
		return c unless c.nil?
		Connection.create(params)
	end
	
	def twin
		Connection.with_subject(self.object).with_object(self.subject).first
	end
	
	def kind
		subject.kind
	end
	
	def connections
		Connection.with_object(self.subject)
	end
	
	def tags
		self.taggings.collect {|c| c.predicate}
	end
	
	def tag_with(tags)
		tags.each do |tag|
			Tagging.create(:taggable => self, :predicate => tag.strip) 
		end
	end

	
	def self.normalize_order(order)
		case order
		when "by_latest"
			"connections.created_at DESC"
		when "by_name"
			"S.label ASC"
		when "by_rank"
			"score DESC"
		else
		end
		
	end
	
	private
	
	def destroy_taggings

		taggings.each do |tagging|
			tagging.destroy
		end
	end
end