module TagsHelper

	
	def ebay(query)
		EbayShopping::Request.new(:find_items, {:query_keywords => query}).response.items
	end
	
	def amazon(query, options = {})
		category = options[:category] || "All"
		Awsomo::Request.new().search(query, :category => category)
	end
	
	
	def h3_for(path)
		
		sentence = ""
		path.tags.each do |tag|
			
			case tag.kind
		    when "location"
		      sentence << "you're at #{tag.content} "
		    when "person"
		       sentence << "you are meeting with #{tag.content} "
				when "quest"
					sentence << "your quest is to #{tag.content} "
				when "item"
					sentence << "you have a #{tag.content} "
				when "topic"
					sentence << "you talk about #{tag.content}"
		    else
		       "Are you ready for this adventure?"
			end
		end
		sentence
		
	end
	
	def nuniverse_for(params)
		params[:left] = render( 
        			:partial => "/nuniverses/#{params[:tag].kind}_left", 
        			:locals => {:tag => params[:tag], :path => @path}
      			) rescue render(
        			:partial => "/nuniverses/quest_left", 
        			:locals => {:tag => params[:tag], :path => @path}
      			)

		params[:body] = render(
	            :partial => "/nuniverses/#{params[:tag].kind}", 
	            :locals => {:tag => params[:tag], :path => @path}
	          ) rescue  render(
	            :partial => "/nuniverses/quest", 
	            :locals => {:tag => params[:tag], :path => @path}
	          )

	     render(
	        :partial => '/nuniverses/instance',
	        :locals => params
	      )
			
	end
	
	
	def new_tag_form(params)
		params[:title] ||= "Add a new #{params[:kind]}"
		render(
			:partial => "/tags/new", 
			:locals => params
			)
	end
	
	
	def list_for(params, &block)
		params[:path]     ||= TaggingPath.new
		params[:header]     = capture(&block)
		params[:reverse]  ||= false
    
		params[:connections] = Tagging.with_path(params[:path]).
		  with_subject(params[:subject]).with_object(params[:object]).by_latest
		
		if params[:reverse]
		  params[:connections] = params[:connections].with_object_kinds(params[:kind])
	  else
	    params[:connections] = params[:connections].with_subject_kinds(params[:kind])
    end
			
		concat(
			render(
				:partial => "/nuniverses/list", 
				:locals => params
			), block.binding
		)
	end
	

end
