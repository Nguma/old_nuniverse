module FactsHelper
	
	def render_fact(fact)

		body = fact.body_with_tag.strip
		tokens = Nuniversal.tokenize(body)

		tokens.each do |token|
				n = Nuniverse.find_by_unique_name(Nuniversal.sanatize(token)) 
				if n
					sub = link_to(n.name, n,:title => n.name, :id =>"Nuniverse-#{n.id}")
				else
					sub = token
				end
					
				body = body.gsub(/\[\[#{token}\]\]/,sub)
			end
			body = replace_urls(body)
			body = body.gsub(/^([\w\-]+)?\:/,'<b style=";font-weight:bold;margin-right:5px">\1</b>')
			body
	end
	
	def replace_urls(str)
		
		str.scan(/((https?:\/\/)?[a-z0-9]+[-.]{1}([a-z0-9]+\.[a-z]{2,5})\S*)/i).each  do |url|
			n = Bookmark.find(:first, :conditions => {:url => url[0]})
			str = str.gsub(url[0],link_to(n.name, n.url, :title => n.name, :id =>"Bookmark-#{n.id}")) if n
		end
		str
	end
end
