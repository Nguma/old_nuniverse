module TagsHelper

	
	def ebay(query)
		EbayShopping::Request.new(:find_items, {:query_keywords => query}).response.items
	end
	
	def amazon(query, options = {})
		category = options[:category] || "All"
		Awsomo::Request.new().search(query, :category => category)
	end
	
	
	def h3_for(tag)
		case tag.kind
	    when "location"
	      "You're at #{tag.content}, <br/>and your quest is to #{tag.crumbs[-2,1].last.content}"
	    when "person"
	       "Are you available?"
			when "quest"
				"You #{tag.crumbs[-2,1].last.content} and your quest is to #{tag.content}"
	    else
	       "Are you ready for this adventure?"
			end
	end
end
