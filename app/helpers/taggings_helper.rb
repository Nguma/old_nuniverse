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
			
end
