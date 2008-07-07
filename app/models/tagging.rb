class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :user
	
	before_save :clean_path
	
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
  
  named_scope :with_path, lambda { |path|
    path.nil? ? {} : {:conditions => ["path rlike ?", "_%s_" % path.ids.join('(_.*)?_')]}
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
  named_scope :by_latest, :order => "taggings.updated_at DESC"
	named_scope :by_name, :order => "tags.content DESC"
	
  # def self.find_taggeds_with(params)
  #   
  #   @path = "_#{params[:path].collect{|c| c.id}.join('(_.*)?_')}_"
  #   @order = params[:order] || "path ASC"
  #   #
  #   # @objects = params[:objects].collect {|o| o.id}.join(',') if params[:objects]
  #   
  #   sub_query = "SELECT taggings.* FROM taggings LEFT JOIN tags ON taggings.#{oid} = tags.id WHERE taggings.path rlike '#{@path}'"
  #   sub_query << " AND taggings.subject_id in (#{params[:subject].id}) " if params[:subject]
  #   sub_query << " AND taggings.object_id in (#{params[:object].id}) " if params[:object]
  #   sub_query << " AND taggings.user_id in (#{params[:user_id]})" if params[:user_id]
  #   sub_query << " AND tags.kind = '#{params[:kind]}'" if params[:kind]
  #   
  #   #raise sub_query if params[:reverse]
  #   Tagging.paginate_by_sql(sub_query, :page => params[:page] || 1 , :per_page => params[:per_page] || 6 )
  # end
	
	protected
	
	# def self.crumbs(path)
	# 		# If there is a way to make mysql order by the path instead of run a select for each,
	# 		# that'd be great!
	# 		@crumbs = []
	# 		path.split('_').reject{|c| c.blank? }.each do |crumb|
	# 			@tag = Tag.find(crumb)
	# 			@tag.crumbs = [@crumbs].flatten
	# 			@crumbs << @tag
	# 		end
	# 		@crumbs
	# 	end
	
	private
	
	def clean_path
	  self.path = self.path.to_s
  end
end
