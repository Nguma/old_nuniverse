class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :user
	
	
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
	
	def self.find_taggeds_with(params)
		
		@path = "_#{params[:path].collect{|c| c.id}.join('(_.*)?_')}_"
		@order = params[:order] || "path ASC"
	 	#
		# @objects = params[:objects].collect {|o| o.id}.join(',') if params[:objects]
		if params[:reverse]
			oid = "subject_id"
			sid = "object_id"
		else
			oid = "object_id"
			sid = "subject_id"
		end
		
		sub_query = "SELECT taggings.* FROM taggings LEFT JOIN tags ON taggings.#{oid} = tags.id WHERE taggings.path rlike '#{@path}'"
		sub_query << " AND taggings.#{sid} in (#{@subjects}) " if @subjects
		sub_query << " AND taggings.#{oid} in (#{@objects}) " if @objects
		sub_query << " AND taggings.user_id in (#{params[:user_id]})" if params[:user_id]
		sub_query << " AND tags.kind = '#{params[:kind]}'" if params[:kind]
		sub_query << " GROUP BY taggings.#{oid} HAVING count(taggings.#{oid}) >= 1 ORDER BY taggings.#{@order}"
		
		#raise sub_query
		Tagging.paginate_by_sql(sub_query, :page => params[:page] || 1 , :per_page => params[:per_page] || 6 )
	end
	
	protected
	
	def self.crumbs(path)
		# If there is a way to make mysql order by the path instead of run a select for each,
		# that'd be great!
		@crumbs = []
		path.split('_').reject{|c| c.blank? }.each do |crumb|
			@tag = Tag.find(crumb)
			@tag.crumbs = [@crumbs].flatten
			@crumbs << @tag
		end
		@crumbs
	end
end
