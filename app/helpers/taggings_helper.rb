module TaggingsHelper
	
	def sentence_for(kind)
		case kind
		when "comment"
			return "said"
		else 
			return "added a #{kind}: "
		end
	end
			
end
