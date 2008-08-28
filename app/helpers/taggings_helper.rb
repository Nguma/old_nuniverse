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
			
end
