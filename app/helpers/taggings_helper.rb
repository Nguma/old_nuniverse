module TaggingsHelper
	
	def sentence_for(kind)
		case kind
		when "comment"
			return "said"
		when "nuniverse"
			return "visited the nuniverse of "
		else 
			return "added a #{kind}: "
		end
	end
	
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
	
	def content_for_tagging(tagging)
		render :partial => "/taggings/#{tagging.kind}", :locals => {:tagging => tagging} rescue render :partial => "/taggings/default", :locals => {:tagging => tagging}
	end
	
	def title_for(object, options ={})
		str = "<h1>"
		str << avatar_for(object)
		str << object.label.capitalize
		str << " according to #{options[:service].capitalize}" if options[:service]
		str << "</h1>"
		str
	end
			
end
