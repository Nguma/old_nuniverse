module TagsHelper

	
	
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
	
	def header_for(params, &block)
		params[:body] = capture(&block)
		concat(
			render(
				:partial => "/nuniverse/header", 
				:locals => params
			), block.binding
		)		
	end
	
	def nuniverse_for(params)
		# params[:left] = render( 
		#         			:partial => "/nuniverse/#{params[:tag].kind}_left", 
		#         			:locals => {:tag => params[:tag], :path => @path}
		#       			) 

		params[:body] = render(
	            :partial => "/nuniverse/#{params[:tag].kind}", 
	            :locals => {:tag => params[:tag], :path => @path}
	          ) 

	     render(
	        :partial => '/nuniverse/instance',
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
		params[:header]    = capture(&block)
		params[:reverse]  ||= false
    
		params[:connections] = Tagging.with_path(params[:path]).by_latest
		
		if params[:reverse]
		  params[:connections] = params[:connections].with_subject_kinds(params[:kind])
	  else
	    params[:connections] = params[:connections].with_object_kinds(params[:kind])
    end
			
		concat(
			render(
				:partial => "/nuniverse/list", 
				:locals => params
			), block.binding
		)
	end
	

end
