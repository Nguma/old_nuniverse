module CommentsHelper
	
	def render_comment(comment)
		body = comment.body
		matches = body.scan(/(\#([\w\-]+)(\?|\,|\.|\!|\s|$))/i)
			
		matches.each_with_index do |item,i|
			n = Nuniverse.find(:first, :conditions => ["unique_name = ?",item[1]])	
			body = body.gsub(/\##{item[1]}/, (link_to n.name, n, :class => "preview-lnk")) unless n.nil?
		end
		
		body = replace_urls(body)
		body
	end
end
