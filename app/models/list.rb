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
		# tags = Nuniverse::Kind.parse(self.label).split("#")
		tags = self.label.downcase.split(/\s/)
		clause = tags.collect {|t| "(T.kind rlike '(^| )(#{t}|#{t.singularize})s?( |$)')"}.join('+')
		
		users = params[:perspective] ? [self.creator] : [grantors, self.creator].flatten 
		params[:order] = "updated_at DESC"
		
		sql = "SELECT DISTINCT T.*, SUM((#{clause})) AS S, COUNT(DISTINCT object_id) from taggings T WHERE "
		sql << "user_id IN (#{users.collect {|u| u.id}.join(',')}) "
		sql << "AND subject_id = #{self.tag.id} " if self.tag
		sql << "GROUP BY object_id HAVING (S >= #{tags.length}) "
		sql << "ORDER BY #{params[:order]} "
		
		Tagging.paginate_by_sql( sql, :page => params[:page] || 1, :per_page => params[:per_page] || 5)
		# Tagging.with_users().labeled_like(params[:label] || nil).with_subject(self.tag).with_tags(tags).order_by(params[:order]).paginate(:page => params[:page], :per_page => params[:per_page])
	end
	
	def permissions(params = {})
		Permission.find(:all, :conditions => ["tags = ? AND (grantor_id = ? OR granted_id = ?)", self.label, self.creator_id, self.creator_id])
		# Permission.for(self).paginate(params).collect {|c| c.user}
	end
	
	def grantors(params = {})
		Permission.find(:all, :conditions => ["tags RLIKE ? AND granted_id = ?", "#{self.label}|#{self.label.pluralize}", self.creator_id]).collect {|c| c.grantor}
	end
	
	
	def self.find_or_create(params)
		l = List.find(:first, :conditions => params)
		return l unless l.nil?
		return List.create(params)		
	end
	
	def title
		self.tag.nil?  ? self.label.capitalize : "#{self.tag.label.capitalize} #{self.label}"
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
