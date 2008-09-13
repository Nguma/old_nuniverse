class List < ActiveRecord::Base

	belongs_to :tag, :class_name => 'Tag'
	belongs_to :creator, :class_name => 'User'
	#after_create :create_tag


	named_scope :bound_to, lambda { |bind| 
			bind.nil? ? {:conditions => 'tag_id IS NULL'} : {:conditions => ['tag_id = ?', bind.id]}
	}
	
	named_scope :created_by, lambda { |user| 
		{:conditions => ['creator_id = ?', user.id]}
	}
	
	named_scope :labeled, lambda { |label| 
		{:conditions => ['label = ?', label]}
	}
	
	def items(params = {})
		params[:page] ||= 1
		Tagging.with_users([self.contributors,self.creator].flatten).with_subject(self.tag).with_tags(Nuniverse::Kind.match(self.label.singularize.downcase).split('#')).order_by(params[:order]).paginate(:page => params[:page], :per_page => params[:per_page])
	end
	
	def contributors(params = {})
		Permission.find(:all, :conditions => ["tags = ?", self.label]).collect {|c| c.user}
		# Permission.for(self).paginate(params).collect {|c| c.user}
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
