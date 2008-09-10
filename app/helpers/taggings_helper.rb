module TaggingsHelper
	
	def elements_proper_to_kind(tagging)
		
		case tagging.kind
		when "list"
			return ""
		when "location"
			return render :partial => "/taggings/info" , :locals => {:info => tagging.object.property('address')}
		when "person"
			return render :partial => "/taggings/info" , :locals => {:info => tagging.object.property('profession')}
		else
		end
	end
	
	def save_button(item, tagging)
		render :partial => "/taggings/bookmark", :locals => {:item => item, :tagging => tagging}
	end
	
	def content_for_tagging(tagging, params = {})
		if params[:service]
			render :partial => "/taggings/#{params[:service]}", :locals => {:tagging => tagging} 
			# rescue render :partial => "/taggings/default", :locals => {:tagging => tagging}			
		else
			render :partial => "/taggings/#{tagging.kinds.first}", :locals => {:tagging => tagging}  rescue render :partial => "/taggings/default", :locals => {:tagging => tagging}
		end
	end
	
	def title_for(tagging, options ={})
		str = "<h1>"
		str << icon_for(tagging.object)
		str << "#{options[:list]}: " if options[:list]
		str << tagging.object.title
		str << "<span class='service'>#{options[:service]}</span>" if options[:service]
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

end
