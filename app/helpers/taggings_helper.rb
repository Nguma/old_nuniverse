module TaggingsHelper
	
	def save_button(item, tagging)
		render :partial => "/taggings/bookmark", :locals => {:item => item, :tagging => tagging}
	end
	
	def content_for_tagging(tagging, params = {})
		if params[:service] == "you" || params[:service] == "everyone"
				render :partial => "/taggings/#{tagging.kind}", :locals => {:tagging => tagging}  rescue render :partial => "/taggings/default", :locals => {:tagging => tagging}
			# rescue render :partial => "/taggings/default", :locals => {:tagging => tagging}			
		else
			render :partial => "/taggings/#{params[:service]}", :locals => {:tagging => tagging} 
		
		end
	end
	
	def title_for(tagging, options ={})
		str = "<h1>"
		# str << "<span style='font-size:30px;color:#999'>"
		# 		if options[:list]
		# 			
		# 			#str << "#{options[:list].tag.label} " if options[:list].tag
		# 			# str << "#{options[:list].label}: " 
		# 		end
		#str << icon_for(tagging.object)
		
		# str << link_to(tagging.kind.capitalize, "/my_nuniverse/all/#{tagging.kind}")
		# str << " </span>"
		str << tagging.object.title
		str << "<span class='service'> by #{options[:service]}</span>" if options[:service]
		str << "</h1>"
		str
	end
	
	def property(property)
		unless !property || property.blank?
			render :partial => "/taggings/property", :locals => {:property => property}
		end
	end

	def box(params)
		params[:dom_class] ||= ""
		params[:title] ||= params[:source].title
		params[:dom_id] ||= params[:title].pluralize.gsub(" ", "_")
		render :partial => "/taggings/box", :locals => params
	end
	
	def tag_box(params) 
		params[:source] ||= current_user.tag
		
		render :partial => "/tags/box", :locals => {
			:items => params[:source].tags,
			:title => "Tags"
		}
	end
	
	
	def content_for_service(params)
		params[:service] ||= @service
		render :partial => "/taggings/#{service}", :locals => {:source => params[:source]}
	else
		render :partial => "/taggings/default_content", :locals => {:source => params[:source]}
	end
	
	

end
