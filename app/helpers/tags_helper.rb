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
		params[:path] ||= TaggingPath.new
		params[:header] = capture(&block)
		params[:reverse] ||= false
		params[:connections] = Tagging.find_taggeds_with(
			:path => params[:path].tags,
			:kind => params[:kind],
			:subject => params[:subject] || nil,
			:object => params[:object] || nil,
			:reverse => params[:reverse],
			:order => "updated_at DESC"
		)
			
		concat(
			render(
				:partial => "/nuniverses/list", 
				:locals => params
			), block.binding
		)
	end
	

end
