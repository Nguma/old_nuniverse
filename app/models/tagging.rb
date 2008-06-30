class Tagging < ActiveRecord::Base
  belongs_to :object, :class_name => "Tag"
	belongs_to :subject, :class_name => "Tag"
	belongs_to :user
	
	
	def self.find_taggeds_with(params)
		
		@context = params[:context].collect {|s| s.id}.join('_')
		# @subjects = params[:subjects].collect {|s| s.id}.join(',')
		# @objects = params[:objects].collect {|o| o.id}.join(',') if params[:objects]
		if params[:reverse]
			oid = "subject_id"
			sid = "object_id"
		else
			oid = "object_id"
			sid = "subject_id"
		end
		
		sub_query = "SELECT * FROM taggings WHERE path rlike '_#{@context}_'"
		sub_query << " AND #{sid} in (#{@subjects}) " if @subjects
		sub_query << " AND #{oid} in (#{@objects}) " if @objects
		sub_query << " AND user_id in (#{params[:user_id]})" if params[:user_id]
		sub_query << " GROUP BY #{oid} HAVING count(#{oid}) >= 1 ORDER BY path ASC"
		
		Tagging.find_by_sql(sub_query)
	end
end
