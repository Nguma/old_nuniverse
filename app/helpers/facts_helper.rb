module FactsHelper
	include Nuniversal
	
	def fact_for(nuniverse, options = {})
		facts = nuniverse.facts
		return nil if facts.empty?
		fact = nuniverse.facts.sphinx(options[:context].unique_name).first rescue nil
		fact = nuniverse.facts.first if fact.nil?
		render_fact(fact) rescue nil
	end
	
	def render_fact(fact)
		# return link_to(fact.name, polymorphic_url(fact), :class => "expand-lnk", :target => "Prop") if !fact.is_a?(Fact)
		body = fact.body_without_category.strip.downcase
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


			# cat = body.scan(/^([\w_]+)\:/)[0]
			# body = body.gsub(/^([\w_]+)\:/, link_to(cat, visit_url(@token.namespace.unique_name, :category => cat.to_s), :class => "category")) if cat
			body.capitalize
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
