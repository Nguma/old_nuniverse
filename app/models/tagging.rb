class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :user
	
	before_save :clean_path
	
	validates_uniqueness_of :object_id, :scope => [:subject_id, :path, :user_id]
	
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

	named_scope :with_address_or_geocode, lambda { |kind|
    kind.nil? ? {} : {:conditions => ["tags.data rlike ?", "#address|#latlng"], :include => :object}
  }

	named_scope :include_object, {:conditions => "tags.id > 0", :include => :object}
	named_scope :groupped, :group => "object_id"
  named_scope :by_latest, :order => "taggings.updated_at DESC"
	named_scope :with_order, lambda { |order|
		case order
		when "name"
			{:include => :object, :order => "tags.content ASC"}
		when "latest"
			{:order => "taggings.updated_at DESC"}
		else
			{}
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

	protected
	
  def self.switch_paths(original_path, new_path)
		c = ActiveRecord::Base.connection();
    c.execute <<-SQL
    UPDATE taggings
    SET path = '_#{new_path}_' + SUBSTRING(path, CHAR_LENGTH('#{original_path.to_s}') + 1)
    WHERE path REGEXP '^#{original_path.to_s}'
    SQL
  end	

	private
	
	def clean_path
	  self.path = self.path.to_s
  end
end
