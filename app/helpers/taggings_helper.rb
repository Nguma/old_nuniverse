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
			render :partial => "/taggings/#{tagging.kind}", :locals => {:tagging => tagging} rescue render :partial => "/taggings/default", :locals => {:tagging => tagging}
		end
	end
	
	def title_for(object, options ={})
		str = "<h1>"
		str << icon_for(object)
		if object.kind == "person"
			str << object.label.titleize
		else
			str << object.label.capitalize
		end
		str << "<span class='service'> according to #{options[:service].capitalize}</span>" if options[:service]
		str << "</h1>"
		str
	end
	
	def property(property)
		unless !property || property.blank?
			render :partial => "/taggings/property", :locals => {:property => property}
		end
	end
			
end
