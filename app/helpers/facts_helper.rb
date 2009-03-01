module FactsHelper
	include Nuniversal
	
	def render_fact(fact)
		return link_to(fact.name, polymorphic_url(fact), :class => "expand-lnk", :target => "Prop") if !fact.is_a?(Fact)
		body = fact.body.strip
		tokens = tokenize(body)

		tokens.each do |token|
				token = token[0]
				n = Nuniverse.find_by_unique_name(sanatize(token)) 
				if n
					sub = link_to(n.name, n,:title => n.name, :id =>"Nuniverse-#{n.id}", :class => "expand-lnk", :target => "Prop" )
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
	
	
	def render_cell(cell, data)
		body = cell.name
		tokens = tokenize_new(body, data)
		tokens.each do |token|
			body = body.gsub(token.formula, token.result)
		end
		body
	end
	
	def render_text(text)
		tokens = tokenize(text)
		tokens.each do |token|
			
			text = text.gsub("[[#{token[0]}]]",link_to(token[0], "/nuniverse-of/#{sanatize(token[0])}"))
		end
		text
	end
	
	def render_property(property)
		
		return nil if property.nil?

		# if property.subject.is_a?(Fact) 
		# 	tokens = tokenize(property.subject.body)
		# 	text = property.subject.body
		# 	tokens.each do |token|
		# 		text = text.gsub("[[#{token[0]}]]",link_to(token[0], polymorphic_url(property), :class => "expand-lnk", :target => "Prop"))
		# 	end
		# else 
			
			text = link_to(property.subject.name, polymorphic_url(property), :class => "expand-lnk", :target => "Prop")
		# end
	
		return text
	end
	
end
