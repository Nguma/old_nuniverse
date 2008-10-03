class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
	
	
	has_many :rankings
	
	before_save :clean_path
	
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

	# named_scope :with_kind_like, lambda { |kinds|
	#     kinds.nil? ? {} : {:select => "taggings.*",:conditions => ["tags.kind rlike ?", "(^|#)#{kinds}($|#)"], :joins => :object}
	#   }

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
	
	# named_scope :order_by, lambda { |order|
	# 		case order
	# 		when "name"
	# 			{ :order => "tags.label ASC"}
	# 		when "latest"
	# 			{:order => "taggings.updated_at DESC"}
	# 		when "rank"
	# 			{:select => "taggings.*", :joins => "LEFT JOIN rankings on taggings.id = rankings.tagging_id", :group => "taggings.id", :order => "SUM(rankings.value) DESC"}
	# 		else
	# 			{:order => "taggings.created_at ASC"}
	# 		end
	# 	}
	# 	
		named_scope :tags, lambda { |object|
			{
				:select => "taggings.* ", 
				:conditions => ["taggings.kind IS NOT NULL AND object_id = ? ", object.id],
				:group => 'taggings.kind'
			}	
		}
	# 	named_scope :groupped, :group => "object_id"
	
	
	
	
	def lists(params = {})
		List.created_by(params[:user] || nil).bound_to(self.object)
	end
	
	
	def kinds
		object.kinds
	end
	
	
	def info
		return "Added to #{subject.label.capitalize}" if kind == "bookmark"
		return description unless description.blank?
		info = ""
		unless object.property('address').blank?
			# info << kinds.last.capitalize
			info << "#{object.property('address')}"
			info << " - #{object.property('tel')}" unless object.property('tel').blank?
		else 
			# info << object.tags.collect {|c| c.kind.gsub('#',' ').capitalize }.join(', ')
		end
		return info
	end
	
	def specific_info
		return  " - \"#{self.connections(:kind => 'comment').first.label.capitalize}\"" unless self.connections(:kind => 'comment').empty?
		return ""
	end
	
	def label
		super.nil? ? object.label : super
	end
	
	def title
		label.capitalize
	end
	
	def path
	  TaggingPath.new(super)
  end
  
  def path=(new_path)
    case new_path
    when TaggingPath
      super(new_path.to_s)
    else
      super
    end
  end

	def full_path
		TaggingPath.new([path.taggings,self].flatten)
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

	def move(original_path, new_path)
	  Tagging.transaction do
      Tagging.switch_paths("#{self.path}", "#{new_path}")
    end
  end

	def self.find_or_create(params)
		params[:kind] ||= nil
		tagging = Tagging.find(:first, :conditions => ['subject_id = ? AND object_id = ? AND user_id = ? AND kind = ?', params[:subject_id], params[:object_id],  params[:owner], params[:kind]])
		tagging = Tagging.create(
			:subject_id => params[:subject_id], 
			:object_id => params[:object_id], 
			:path => params[:path], 
			:user_id => params[:owner].id,
			:kind => params[:kind] || nil,
			:description => params[:description] || nil
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
	# with group and having clauses
	# -- NOTE --
	# HAVING clause simulates the requirement that all tags should be present. 
	# -1 is added to simulate the "OR" statement of the fact that the list label is also passed.
	def self.select(params = {})
		params[:users] ||= []
		params[:tags] ||= []
		params[:subject] ||= nil
		order = Tagging.order(params[:order])
		# Building clause out of tags and title if present
		# Pluralized and singularized versions of each tag is passed as a regexp match.
		# Same is done with title if exists.
		clause = params[:tags].collect {|t| " (T.kind rlike '(^| )(#{t.pluralize}|#{t.singularize})( |$)')"}.join('+')
		clause << " + (CONCAT(SUBJ.label, ' ', T.kind) rlike '(^| )(#{params[:title].pluralize}|#{params[:title].singularize})( |$)') " if params[:title]
		user_ids = params[:users].collect {|u| u.id}.join(',')
		
		sql = "SELECT DISTINCT T.*, COUNT(DISTINCT object_id) "
		sql << ", SUM((#{clause})) AS S " unless params[:tags].empty?
		sql << ", SUM(K.value) AS votes " if params[:order] == "by_vote"
		sql << "FROM taggings T LEFT OUTER JOIN tags on (object_id = tags.id) "
		sql << "LEFT OUTER JOIN tags SUBJ on subject_id = SUBJ.id " unless params[:tags].empty?
		sql << "LEFT OUTER JOIN rankings K on (K.tagging_id = T.id AND K.user_id in (#{user_ids})) " if params[:order] == "by_vote"
		sql << "WHERE T.user_id IN (#{user_ids}) " 
		sql << "AND T.subject_id = #{params[:subject].id} " if params[:subject]
		sql << "AND tags.label rlike '^.?#{params[:label]}'" if params[:label]
		
		sql << "GROUP BY object_id "
		
		sql << "HAVING (S >= #{params[:tags].length}) " unless params[:tags].empty?
		sql << "ORDER BY #{order} "

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
	
	def command
		return self.label.split(' ').last.singularize
	end
	
	
	def update_with(params)
		self.object.kind = params[:kind] if params[:kind]
		self.object.replace_property('address', params[:address].to_s) if params[:address]
		self.object.replace_property("tel", params[:tel]) if params[:tel]		
		self.object.replace_property("latlng", params[:latlng]) if params[:latlng]
		self.object.url = params[:url] if params[:url]
		self.object.description = params[:description] if params[:description]
		self.object.save
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
			return "tags.label ASC"
		when "by_vote"
			return "votes DESC"
		else
			return "T.updated_at DESC"
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
