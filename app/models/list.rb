class List < ActiveRecord::Base

	belongs_to :tag, :class_name => 'Tag'
	belongs_to :creator, :class_name => 'User'
	#after_create :create_tag
	cattr_reader :per_page
  @@per_page = 5

	named_scope :bound_to, lambda { |bind| 
			bind.nil? ? {:conditions => 'tag_id IS NULL'} : {:conditions => ['tag_id = ?', bind.id]}
	}
	named_scope :created_by, lambda { |user| 
		{:conditions => ['creator_id = ?', user.id]}
	}
	
	def items(params = {})
		params[:page] ||= 1
		Tagging.with_user(self.creator).with_subject(self.tag).with_tags(Nuniverse::Kind.match(self.label).split('#')).paginate(params)
	end
	
	def contributors(params = {})
		Permission.for(self).paginate(params).collect {|c| c.user}
	end
	
	
	def self.find_or_create(params)
		l = List.find(:first, :conditions => params)
		return l unless l.nil?
		return List.create(params)
		
	end
	
	protected
	def create_tag
		self.tag = Tag.create(
			:label => self.label,
			:kind => 'list'
		)
		self.save
	end
	

	
end
