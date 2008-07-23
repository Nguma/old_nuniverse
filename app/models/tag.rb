class Tag < ActiveRecord::Base
  has_one :avatar
	
	validates_presence_of :content, :kind
	
	def self.connect(params)
		@object = Tag.find_by_content_and_kind_and_url(
		  params[:content], params[:kind], params[:url]
		)
		if @object.nil?
			@object = Tag.create(
				:content      => params[:content], 
				:kind         => params[:kind],
				:description  => params[:description] || "",
				:url          => params[:url],
				:source       => params[:source],
				:data         => params[:data]
			)
		else
			@object.description = params[:description] || @object.description
			@object.url = params[:url] || @object.url
			@object.save	
		end
		
		
		
		unless params[:user_id].nil?
			@subject = Tag.find(params[:path].split('_').last)

			@tagging = Tagging.create(
				:subject 	=> @subject,
				:object 	=> @object,
				:path    	=> "_#{params[:path]}_",
				:user_id	=> params[:user_id],
				:restricted => params[:restricted]
			)
		end
		
		@tagging
	end
	
	def has_address?
		return true if kind == "country" || "city" || "continent"
		return true if description.match(/#address\s.+/)
		return false
	end
	
	def address
		ad = description.scan(/#address[\s]+([^#|\[|\]]+)*/)[0]
		return ad[0] if ad
		return content
	end
	# def self.find_taggeds_with(params)
	# 		
	# 		@context = params[:context].collect {|s| s.id}.join('_')
	# 		# @subjects = params[:subjects].collect {|s| s.id}.join(',')
	# 		# @objects = params[:objects].collect {|o| o.id}.join(',') if params[:objects]
	# 		if params[:reverse]
	# 			oid = "subject_id"
	# 			sid = "object_id"
	# 			
	# 		else
	# 			oid = "object_id"
	# 			sid = "subject_id"
	# 		end
	# 		
	# 		sub_query = "SELECT #{oid} FROM taggings WHERE path rlike '_#{@context}_'"
	# 		sub_query << " AND #{sid} in (#{@subjects}) " if @subjects
	# 		sub_query << " AND #{oid} in (#{@objects}) " if @objects
	# 		sub_query << " AND user_id in (#{params[:user_id]})" if params[:user_id]
	# 		sub_query << " GROUP BY #{oid} HAVING count(#{oid}) >= 1 ORDER BY path ASC"
	# 		query = "SELECT tags.* FROM tags WHERE tags.id in (#{sub_query})"
	# 		query << " AND kind = '#{params[:kind]}'" if params[:kind]
	# 		query << " ORDER BY content DESC"
	# 		
	# 		Tag.find_by_sql(query)
	# 	end
	
  
  protected
  
end
