class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
	
	has_many :rankings
	
	before_save :clean_path
	
	before_destroy :destroy_connections
	
	def kinds
		object.kinds
	end
	
	def kind
		kinds.last
	end
	
	def info
		return description unless description.blank?
		return object.info
	end
	
	def label
		super.nil? ? object.label : super
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
		return degree.nil? ? {:select => "taggings.*",:conditions => ["path rlike ?", "_%s_$" % path.ids.join('(_.*)?_')]} : {:conditions => ["path rlike ?", "_%s_" % path.ids.join('(_.*)?_')]}
  }
  named_scope :with_path_ending, lambda { |path|
    path.nil? ? {} : {:select => "taggings.*", :conditions => ["path rlike ?", "_%s_$" % path.ids.join('(_.*)?_')]}
  }
  named_scope :with_path_beginning, lambda { |path|
    path.nil? ? {} : {:select => "taggings.*", :conditions => ["path rlike ?", "^_%s_" % path.ids.join('(_.*)?_')]}
  }
  named_scope :with_exact_path, lambda { |path|
    path.nil? ? {} : {:select => "taggings.*", :conditions => ["path rlike ?", "^_%s_$" % path.ids.join('_')]}
  }
  named_scope :with_subject, lambda { |subject|
    subject.nil? ? {} : {:select => "taggings.*",:conditions => ["subject_id = ?", subject.id]}
  }
  named_scope :with_object, lambda { |object|
    object.nil? ? {} : {:select => "taggings.*",:conditions => ["object_id = ?", object.id]}
  }
  named_scope :with_user, lambda { |user|
    user.nil? ? {} : {:select => "taggings.*",:conditions => ["taggings.user_id = ?", user.id]}
  }

	named_scope :with_kind_like, lambda { |kinds|
    kinds.nil? ? {} : {:select => "taggings.*",:conditions => ["tags.kind rlike ?", "(^|#)#{kinds}($|#)"], :joins => :object}
  }

	named_scope :with_address_or_geocode, lambda { |kind|
    kind.nil? ? {} : {:select => "taggings.*",:conditions => ["tags.data rlike ?", "#address|#latlng"], :include => :object}
  }

	named_scope :groupped, :group => "object_id"
	named_scope :with_order, lambda { |order|
		case order
		when "name"
			{:select => "taggings.*", :joins => :object, :order => "tags.label ASC"}
		when "latest"
			{:order => "taggings.updated_at DESC"}
		when "rank"
			{:select => "taggings.*", :joins => "LEFT JOIN rankings on taggings.id = rankings.tagging_id", :group => "taggings.id", :order => "SUM(rankings.value) DESC"}
		else
			{:order => "taggings.created_at ASC"}
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
			params[:order] ||= "latest"
			params[:kind] ||= nil
			params[:path] ||= nil
			
			if self.kind == "list"
				query = Tagging.with_user(self.owner).with_path(self.full_path, true).with_kind_like(params[:kind]).with_order(params[:order]).paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 5)
			else
				query = Tagging.with_user(self.owner).with_subject(self.object).with_kind_like(params[:kind]).with_order(params[:order]).paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 5)
			end
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
	
	def toggle
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
