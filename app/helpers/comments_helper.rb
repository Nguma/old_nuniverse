module CommentsHelper
	
	def render_comment(comment)
		body = comment.body
		tokens = Token.find(body)

		tokens.each do |token|
			unless token.nil?
				n = token.namespace
				unless n.nil?
					# 
					body = body.gsub(token.regxp, link_to(token.to_s, token.uri, :style => "color:#369"))
				end
			end
		end
		"\"#{body.capitalize}\""
	end
end
