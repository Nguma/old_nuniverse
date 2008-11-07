class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
	
	
	has_many :rankings

	cattr_reader :per_page 
  @@per_page = 5

	#before_destroy :destroy_connections

  named_scope :with_subject, lambda { |subject|
    subject.nil? ? {} : {:conditions => ["subject_id = ?", subject.id]}
  }
  named_scope :with_object, lambda { |object|
    object.nil? ? {} : {:select => "taggings.*",:conditions => ["object_id = ?", object.id]}
  }
  named_scope :with_user, lambda { |user|
    user.nil? ? {} : {:conditions => ["taggings.user_id = ?", user.id]}
  }

	named_scope :with_users, lambda { |users| 
		users.empty? ? {} : {:conditions => ["user_id in (?)", users.collect {|u| u.id}]}
	}
	
	named_scope :labeled_like, lambda { |label| 
		label.nil? ? {} : {:conditions => ["tags.label rlike ?", "^.?#{label}"]}
	}

	named_scope :with_address_or_geocode, lambda { |kind|
    kind.nil? ? {} : {:select => "taggings.*",:conditions => ["tags.data rlike ?", "#address|#latlng"], :include => :object}
  }

	# Sad, but paginate doesnt seem to work with the following:
	# named_scope :with_tags, lambda { |tags|
	# 		clause = tags.collect {|t| "(taggings.kind rlike '(^| )(#{t}|#{t.singularize})s?( |$)')"}.join('+')
	# 		tags.empty? ? {} :
	# 		{
	# 			:select => "DISTINCT taggings.*, SUM((#{clause})) AS S, COUNT(DISTINCT object_id)",
	# 			:include => :object,
	# 			:conditions => "taggings.kind IS NOT NULL",
	# 			:group => "taggings.object_id HAVING (S >= #{tags.length}) "
	# 		}
	# 
	# 	}

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
		info = params[:info] || Nuniverse::Kind.matching_info(params[:kind])
		
		if info == 'price'
			return "#{object.property('price')} on #{object.service.capitalize}" unless object.service.nil?
		end
		# return "#{self.owner.login.capitalize}" if info == "comment"
		return description if info == 'description'
		return object.property('address') if info == 'address'

		return self.connections(:kind => info).first.label rescue ""
	end
	
	def label
		super.nil? ? object.label : super
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
		tagging = Tagging.find(:first, :conditions => ['subject_id = ? AND object_id = ? AND user_id = ? AND kind = ?', params[:subject_id], params[:object_id],  params[:user], params[:kind]])
		tagging = Tagging.create(
			:subject_id => params[:subject_id], 
			:object_id => params[:object_id], 
			:path => params[:path], 
			:user_id => params[:user].id,
			:kind => params[:kind] || nil,
			:description => params[:description] || nil,
			:public => params[:public] || 1
		) if tagging.nil? rescue nil
		tagging
	end
	
	def connections(params = {})
		Tagging.select(
			:users => [self.owner], 
			:subject => self.object, 
			:tags => Nuniverse::Kind.match(params[:kind] ||= "").split('#'), 
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
	
		params[:users] ||= []
		params[:current_user] ||= params[:users].first
		params[:tags] ||= []
		params[:subject] ||= nil
		order = Tagging.order(params[:order])
	
		user_ids = params[:users].collect {|u| u.id}.join(',')
		
		
		# Building clause out of tags and title if present
		# Pluralized and singularized versions of each tag is passed as a regexp match.
		# Same is done with title if exists.
		having_clauses = []
		query = Regexp.escape(params[:tags].join(' '))
		# 
		# sql = "SELECT DISTINCT T.*, CONCAT('##',GROUP_CONCAT(DISTINCT S.label, ' ', T.kind, '##', T.kind SEPARATOR '##'),'##') AS GC , (GROUP_CONCAT(DISTINCT user_id) rlike '#{params[:current_user].id}') AS personal "
		# sql << "	FROM taggings T LEFT OUTER JOIN tags S on S.id = T.subject_id "
		# sql << " LEFT OUTER JOIN tags on (object_id = tags.id) " 
		# sql << " WHERE (T.user_id IN (#{user_ids}) "
		# sql << " OR T.public = 1 " if params[:perspective] == 'everyone'
		# sql << ")"
		# sql << " AND CONCAT(S.label,' ',T.kind) rlike (\"(#{query})$\") " if params[:tags]
		# sql << " AND T.subject_id = #{params[:subject].id} " if params[:subject]
		# sql << " AND tags.label rlike '^(.*\s)?#{Regexp.escape(params[:label].gsub(/^the\s|a\s/,''))}(\s.*)?'" if params[:label]
		# sql << " GROUP BY object_id "
		# sql << " HAVING (GC rlike \"###{query}##\") " if params[:tags].length > 1
		# sql << " ORDER BY #{order} "
		
		
		sql = "SELECT DISTINCT TA.*, (GROUP_CONCAT(DISTINCT user_id) rlike '#{params[:current_user].id}') AS personal "
		sql << " FROM taggings TA LEFT OUTER JOIN tags S on S.id = TA.subject_id "
		sql << " LEFT OUTER JOIN tags O on O.id = TA.object_id "
		
		case params[:perspective]
		when "you"
			sql << " WHERE (TA.user_id = #{params[:current_user].id}) "
		when "everyone"
			sql << " WHERE (TA.user_id = (#{params[:current_user].id}) OR  public = 1 ) "
		else
			sql << " WHERE (TA.user_id IN (#{user_ids}) AND public = 1) "
		end
		sql << " AND '#{query}' rlike CONCAT('^(',S.label,'|',S.kind,')?\s?(',O.kind,'|',TA.kind,')$') " if params[:tags]
		sql << " AND TA.subject_id = #{params[:subject].id} " if params[:subject]
		sql << " AND O.label rlike '^(.*\s)?#{Regexp.escape(params[:label].gsub(/^the\s|a\s/,''))}(\s.*)?'" if params[:label]
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
	
	def destroy_connections
		self.connections.each do |c|
			c.destroy
		end
	end
	
	def clean_path
	  self.path = self.path.to_s
  end
end
