module CommentsHelper
	
	def render_comment(comment)
		body = comment.body
		tokens = Nuniversal.tokenize(body)
		tokens.each do |token|
			body = body.gsub(/\[\[#{token}\]\]/,link_to(token, nuniverse_by_name_url(Nuniversal.sanatize(token))))
		end
		# matches.each_with_index do |item,i|
		# 			n = Nuniverse.find(:first, :conditions => ["unique_name = ?",item[1]])	
		# 			body = body.gsub(/\##{item[1]}/, (link_to n.name, n, :class => "preview-lnk")) unless n.nil?
		# 		end
		# 		
		body = replace_urls(body)
		body
	end
end
