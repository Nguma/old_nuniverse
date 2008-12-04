class Connection < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	
	has_many :origins, :foreign_key => "connection_id"
	# belongs_to :user, :class_name => "Tag"
	
	has_many :taggings
	
	before_destroy :destroy_taggings
	
	named_scope :with_subject, lambda { |subject|
    subject.nil? ? {} :  {:conditions => ["connections.subject_id in (?)", subject.to_a.collect {|c| c.is_a?(Tag) ? c.id : c}] } 

  }
  named_scope :with_object, lambda { |object|
    object.nil? ? {} : {:conditions => ["connections.object_id in (?)", object.to_a.collect {|c| c.is_a?(Tag) ? c.id : c}]}

  }
  named_scope :with_user, lambda { |user|
    user.nil? ? {} : {:conditions => ["origins.user_id in (?)", user.to_a.collect{|c| c.is_a?(Tag) ? c.id : c.tag_id}], :joins => ['origins on origins.connection_id = connections.id']}
  }

	

	named_scope :tagged, lambda { |query| 
		query.nil? ? {} : {
			:select => "connections.*",
			:conditions => ["taggings.kind rlike ?", query.to_a.join('|')], 
			:joins => "INNER JOIN tags O on O.id = connections.object_id iNNER JOIN tags S on S.id = connections.subject_id LEFT OUTER JOIN taggings ON taggings.connection_id = connections.id ",
		
			:group => "connections.object_id HAVING count(connection_id) >= #{query.to_a.length}"
		}
	}
	
	named_scope :named, lambda { |name| 
		name.nil? ? {} : {
			:conditions => ["tags.label rlike ?", "^#{name}"],
			:joins => "LEFT OUTER JOIN taggings ON taggings.connection_id = connections.id INNER JOIN tags on tags.id = connections.object_id"
		}
	}

	named_scope :with_kind, lambda { |kind| 
		kind.nil? ? {} : {:conditions => ["tags.kind = ?", kind], 
			:joins => "INNER JOIN tags on connections.object_id = tags.id LEFT OUTER JOIN taggings ON taggings.connection_id = connections.id "
			}
	}
	named_scope :by_kind, :group => "taggings.kind", :select => ["connections.*, count(distinct object_id) AS counted"], :joins => "LEFT OUTER JOIN taggings on taggings.connection_id = connections.id "
	named_scope :distinct, :group => "connections.object_id", :select => ["connections.*, count(distinct object_id) AS counted"]
	
	named_scope :with_user_list, :group => "connections.object_id", :select => ["connections.*, GROUP_CONCAT(connections.user_id SEPARATOR ',') AS users"]
	
	named_scope :order_by, lambda { |order| 
		order.nil? ? {} : { :order => Connection.normalize_order(order) }
		
	}
	def self.find_or_create(params)
		c = Connection.with_subject(params[:subject]).with_object(params[:object]).with_user(params[:user]).first
		return c unless c.nil?
		params[:user] = params[:user].tag
		Connection.create(params)
	end
	
	def kind
		taggings.first.kind rescue object.kind
	end
	
	def self.normalize_order(order)
		case order
		when "by_latest"
			"connections.created_at DESC"
		when "name"
			"object.label ASC"
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