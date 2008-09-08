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
			render :partial => "/taggings/#{tagging.kinds.first}", :locals => {:tagging => tagging}  #rescue render :partial => "/taggings/default", :locals => {:tagging => tagging}
		end
	end
	
	def title_for(tagging, options ={})
		str = "<h1>"
		str << icon_for(tagging.object)
		str << "#{tagging.subject.title}: #{tagging.object.title}"
		str << "<span class='service'>#{options[:service]}</span>" if options[:service]
		str << "</h1>"
		str
	end
	
	def property(property)
		unless !property || property.blank?
			render :partial => "/taggings/property", :locals => {:property => property}
		end
	end
	
	
	def list(params)
		params[:source] ||= current_user
		params[:dom_class] ||= ""
		params[:kind] ||= nil
		params[:title] ||= params[:kind] ? params[:kind].pluralize : ""
		params[:items] ||= params[:source].connections(:kind => params[:kind])
		params[:toggle] ||= "##{params[:kind].downcase} " 
		params[:dom_id] ||= params[:title].pluralize
		render :partial => "/taggings/list_box", :locals => params
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
			:items => TaggingPath.new(Tagging.with_object(params[:source]).collect{|c| c.path}.join('')).tags,
			:title => "Tags"
		}
	end

end
