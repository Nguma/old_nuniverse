module TaggingsHelper
	
	def save_button(item, tagging)
		render :partial => "/taggings/bookmark", :locals => {:item => item, :tagging => tagging}
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
		if !service_is_nuniverse?
			render :partial => "/taggings/#{service}", :locals => {:source => params[:source]}
		else
			render :partial => "/taggings/default_content", :locals => {:source => params[:source]}
		end
	end
	
	def save_button(item, params = {})
		params[:item] = item
		render :partial => "/taggings/manage", :locals => params
	end
	
	def connections(params = {})
		params[:service] ||= @service
		params[:perspective] = @perspective
		params[:tags] = [params[:kind]] || [@kind]
		params[:source] ||= @source
		if service_is_nuniverse?(:service => params[:service])
			Nuniverse::Connection.find(params)
		else
			service_items(:service => params[:service])
		end
		
	end

end
