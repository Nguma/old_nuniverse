class Tagging < ActiveRecord::Base
	belongs_to :taggable, :polymorphic => true 
	belongs_to :tag
	
	
	define_index do
		indexes tag.label, :as => :predicate
		set_property :delta => true
	end
	# has_many :rankings

	cattr_reader :per_page 
  @@per_page = 5

	
	def predicate
				tag.label
			end

	named_scope :with_connection, lambda {|connection| 
		id.nil? ? {} : {:conditions => ["taggable_id in (?)", connection.to_a.collect{ |c| c.id}] } 
	}
	
	named_scope :named, lambda { |kind| 
		kind.nil? ? {} : {:conditions => ['predicate = ? ', kind]}
	}
	
	named_scope :with_user, lambda {|user| 
		user.nil? ? {} : {:conditions => ['connections.user_id in (?)', user.to_a.collect {|c| c.is_a?(User) ? c.tag_id : c.id} ]}
	}
	
	named_scope :with_subject, lambda {|subject| 
		subject.nil? ? {} : {:joins => "INNER JOIN connections ON connections.id = taggings.connection_id", :conditions => ['connections.subject_id = ?', subject.id]}
	}
	
	named_scope :with_object, lambda {|object| 
		object.nil? ? {} : {:joins => "INNER JOIN connections ON connections.id = taggings.connection_id", :conditions => ['connections.object_id = ?', object.id]}
	}
	
	named_scope :distinct, :group => :kind
	
	named_scope :with_users, lambda { |users| 
		users.empty? ? {} : {:conditions => ["user_id in (?)", users.collect {|u| u.id}]}
	}
	
	named_scope :labeled_like, lambda { |label| 
		label.nil? ? {} : {:conditions => ["tags.label rlike ?", "^.?#{label}"]}
	}

	named_scope :with_address_or_geocode, lambda { |kind|
    kind.nil? ? {} : {:select => "taggings.*",:conditions => ["tags.data rlike ?", "#address|#latlng"], :include => :object}
  }

	named_scope :gather, :select => " *, count(DISTINCT tag_id) AS counted",  :group => 'tag_id'


	named_scope :tags, lambda { |object|
		{
			:select => "taggings.* ", 
			:conditions => ["taggings.kind IS NOT NULL AND object_id = ? ", object.id],
			:group => 'taggings.kind'
		}	
	}	
	
	# Lists associated with this tagging
	def lists(params = {})
		List.created_by(params[:user] || nil).bound_to(self.object)
	end
	
	
	def kinds
		object.kinds
	end
	
	def url
		object.url
	end
	
	
	def info(params)
		params[:kind] ||= self.kind
		info = params[:info] || Nuniversal::Kind.matching_info(params[:kind])
		
		if info == 'price'
			return "#{object.property('price')} on #{object.service.capitalize}" unless object.service.nil?
		end
		return description if info == 'description'
		return object.property('address') if info == 'address'

		return self.connections(:kind => info).first.label rescue ""
	end
	
	def label
		object.label 
	end
	
	def title
		label.capitalize
	end
	
	def votes
		super rescue nil
	end
	
	def add_image(params)
		object.add_image(params)
	end
  
	def properties
		self.connections(:kind => "property")
	end

	def self.find_or_create(params)
		params[:kind] ||= nil
		tagging = Tagging.with_subject(params[:subject]).with_object(params[:object]).with_user(params[:user]).with_kind(params[:kind]).first
		tagging = Tagging.create(
			:subject => params[:subject], 
			:object => params[:object], 
			:user_id => params[:user].tag_id,
			:kind => params[:kind] || nil,
			:description => params[:description] || nil,
			:public => params[:public] || 1
		) if tagging.nil? 
		tagging
	end
	
	def connections(params = {})
		Tagging.select(
			:users => [self.owner], 
			:subject => self.object, 
			:tags => Nuniversal::Kind.match(params[:kind] ||= "").split('#'), 
			:page => params[:page], 
			:per_page => params[:per_page], 
			:order => params[:order] ||= "latest"
		)
	end

	# Select
	# Selects matching taggings according to passed arguments
	# I Wish i could use named_scope here but will_paginate gets apparently capricious 
	# Performs a rlike against each tag to validate their existence.
	def self.select(params = {})
		
		current_user = params[:perspective].user
		params[:user] ||= params[:perspective].members
		params[:subject] ||= nil
		
		order = Tagging.order(params[:order])

		# Building clause out of tags and title if present
		# Pluralized and singularized versions of each tag is passed as a regexp match.
		# Same is done with title if exists.
		
		
		sql = "SELECT DISTINCT TA.* "
		sql << ", (GROUP_CONCAT(DISTINCT user_id) rlike '#{current_user.tag.id}') AS personal"
		sql << ", (GROUP_CONCAT(DISTINCT TA.kind SEPARATOR ', ') ) AS current_tags "
		sql << " FROM taggings TA LEFT OUTER JOIN tags S on S.id = TA.subject_id "
		sql << " LEFT OUTER JOIN tags O on O.id = TA.object_id "

		case params[:perspective].kind
		when "personal"
			sql << " WHERE (TA.user_id = #{params[:user].id}) "
		when "everyone"
			sql << " WHERE (TA.user_id = (#{params[:user].id}) OR  public = 1 ) "
		else
			sql << " WHERE (TA.user_id IN (#{params[:user].to_a.collect {|u| u.id}.join(',')}) AND public = 1) "
		end
		
		if params[:tags]
			query = Regexp.escape(params[:tags].to_a.join(' ').gsub("'","\\'")) 
			
			sql << " AND '#{query.singularize}' rlike CONCAT('(',S.label,'|',S.kind,')?\s?(',O.kind,'|',TA.kind,')$') "
		end
		
		sql << " AND CONCAT(O.kind,' ',TA.kind) rlike '(\s|^)#{params[:kind]}'" if params[:kind]
		sql << " AND TA.subject_id = #{params[:subject].id} " if params[:subject]
		sql << " AND CONCAT(O.label,' ',O.kind,' ',TA.kind) rlike '^(.*\s)?#{params[:label].gsub(/^the\s|a\s/,'').gsub(/\'|\"/,'\.')}(\s.*)?'" if params[:label]
		sql << " GROUP BY object_id "
		sql << " ORDER BY #{order} "

		Tagging.paginate_by_sql( sql, :page => params[:page] || 1, :per_page => params[:per_page] || 3)
	end
	
	def contributors(params = {})
		ids = self.full_path.ids || []
		Permission.find(:all, :conditions => ['tagging_id IN (?)', ids]).collect {|p| p.user}
	end
	
	def authorized_users
		[contributors, self.owner].flatten
	end
	
	def siblings
		# Add a method to find siblings from parent
	end
	
	def images
		Image.find(:all, :conditions => ['tag_id = ?', object.id])
	end
	
	def is_a_list?
		return true if kind == "list"
		return false
	end
	
	def has_description?
		return true if !description.blank?
		return false
	end
	
	def command
		return self.label.split(' ').last.singularize
	end
	
	
	def update_with(params)
			self.object.update_with(params)
	end
	
	protected
	
  def self.switch_paths(original_path, new_path)
		c = ActiveRecord::Base.connection();
    c.execute <<-SQL
    UPDATE taggings
    SET path = '_#{new_path}_' + SUBSTRING(path, CHAR_LENGTH('#{original_path.to_s}') + 1)
    WHERE path REGEXP '^#{original_path.to_s}'
    SQL
  end	

	def self.order(ord)
		case ord
		when "by_name"
			return "O.label ASC"
		when "by_vote"
			return "votes DESC"
		when "by_related_date"
			return "O.related_date DESC"
		else
			return "created_at DESC"
		end
		
	end

	private
	

	
	def clean_path
	  self.path = self.path.to_s
  end
end
