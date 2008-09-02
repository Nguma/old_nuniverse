class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
	
	has_many :rankings
	
	before_save :clean_path
	
	before_destroy :destroy_connections
	
	def kind
		object.kind
	end
	
	def info
		return description unless description.blank?
		return object.info
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
	
	def rank
		return 0 if rankings.length == 0
		((rankings.sum :value).to_i / rankings.length).floor
	end
  

  named_scope :with_path, lambda { |path,degree|
		return {} if path.nil?
		return degree.nil? ? {:conditions => ["path rlike ?", "_%s_$" % path.ids.join('(_.*)?_')]} : {:conditions => ["path rlike ?", "_%s_" % path.ids.join('(_.*)?_')]}
  }
  named_scope :with_path_ending, lambda { |path|
    path.nil? ? {} : {:conditions => ["path rlike ?", "_%s_$" % path.ids.join('(_.*)?_')]}
  }
  named_scope :with_path_beginning, lambda { |path|
    path.nil? ? {} : {:conditions => ["path rlike ?", "^_%s_" % path.ids.join('(_.*)?_')]}
  }
  named_scope :with_exact_path, lambda { |path|
    path.nil? ? {} : {:conditions => ["path rlike ?", "^_%s_$" % path.ids.join('_')]}
  }
  named_scope :with_subject, lambda { |subject|
    subject.nil? ? {} : {:conditions => ["subject_id = ?", subject.id]}
  }
  named_scope :with_object, lambda { |object|
    object.nil? ? {} : {:conditions => ["object_id = ?", object.id]}
  }
  named_scope :with_user, lambda { |user|
    user.nil? ? {} : {:conditions => ["user_id = ?", user.id]}
  }
  named_scope :with_subject_kinds, lambda { |kind|
    kind.nil? ? {} : {:conditions => ["tags.kind = ?", kind], :include => :subject}
  }
	named_scope :with_object_kinds, lambda { |kind|
    kind.nil? ? {} : {:conditions => ["tags.kind = ?", kind], :include => :object}
  }

	named_scope :with_kind_like, lambda { |kinds|
    kinds.nil? ? {} : {:conditions => ["tags.kind rlike ?", "^#{kinds}$"], :include => :object}
  }

	named_scope :with_address_or_geocode, lambda { |kind|
    kind.nil? ? {} : {:conditions => ["tags.data rlike ?", "#address|#latlng"], :include => :object}
  }

	named_scope :with_kind, lambda {|kind| 
		kind.nil? ? {} : {:conditions => ["kind = ?", kind]}
	}

	named_scope :include_object, {:conditions => "tags.id > 0", :include => :object}
	named_scope :groupped, :group => "object_id"
  named_scope :by_latest, :order => "taggings.updated_at DESC"
	named_scope :with_order, lambda { |order|
		case order
		when "name","label"
			{:include => :object, :order => "tags.label ASC"}
		when "latest"
			{:order => "taggings.updated_at DESC"}
		when "rank"
			{:select => "*", :joins => "LEFT JOIN rankings on taggings.id = rankings.tagging_id", :group => "rankings.tagging_id", :order => "SUM(rankings.value) DESC"}
		else
			{:include => :object, :order => "tags.label ASC"}
		end
	}


	def move(original_path, new_path)
	  Tagging.transaction do
      Tagging.switch_paths("#{self.path}", "#{new_path}")
    
      # Tagging.find(:first, :conditions => {
      #         :subject_id => self.path.last_tag.id,
      #         :object_id  => self.id,
      #         :user_id    => self.user_id,
      #         :path       => self.path
      #       }).update_attributes(
      #         :subject_id => new_path.split('_').last,
      #         :path       => new_path
      #       )
    end
  end

	def self.find_or_create(params)
		tagging = Tagging.find(:first, :conditions => ['subject_id = ? AND object_id = ? AND path = ? AND user_id = ?', params[:subject_id], params[:object_id], params[:path], params[:owner]])
		tagging = Tagging.create(:subject_id => params[:subject_id], :object_id => params[:object_id], :path => params[:path], :user_id => params[:owner].id) if tagging.nil?
		tagging
	end
	
	def connections(params = {})
		 Tagging.with_exact_path(self.full_path).include_object.with_object_kinds(params[:filter] || nil).with_order(params[:order] || 'name')
		# case params[:order]
		# 		when "latest"
		# 			order = "updated_at DESC"
		# 		when "name"
		# 			order = "tags.label ASC"
		# 		when "rank"
		# 			order = "rankings.value DESC"
		# 		else
		# 			order = "tags.label ASC"
		# 		end
		# 		Tagging.paginate( 
		# 			:conditions => "path = '#{self.full_path}'",
		# 			:include => [:rankings, :object],
		# 			:order => order,
		# 			:page => params[:page] || 1,
		# 			:per_page => 10
		# 			)
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
		Avatar.find(:all, :conditions => ['tag_id = ?', object.id])
	end
	
	def is_a_list?
		return true if kind == "list"
		return false
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

	def destroy_connections
		self.connections.each do |c|
			c.destroy
		end
	end


	private
	
	def clean_path
	  self.path = self.path.to_s
  end
end
