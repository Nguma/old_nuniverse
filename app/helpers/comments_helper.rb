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
	
	def render_tweet(tweet)
		tweet = tweet.gsub(/(http\:\/\/[^\s]+)/,link_to('\1','\1',:target => "_blank"))
		tweet = tweet.gsub(/\@([\w\_]+)/i,link_to('@\1','http://www.twitter.com/\1', :target => '_blank'))
		tweet.scan(/\#([\w\_\-]+)/i).flatten.each do |s|
			n = Nuniverse.find_by_unique_name(s)
			tweet = tweet.gsub(/\##{s}/i,wdyto_url(n)) unless n.nil?
		end
		
		tweet
	end
end
