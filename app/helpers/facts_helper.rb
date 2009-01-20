module FactsHelper
	
	def render_fact(fact)

		body = fact.body_with_tag
		
			Nuniversal.tokenize(body).each do |token|
				
				n = Nuniverse.find_by_unique_name(token)

				body = body.gsub(/##{token}/,link_to(n.name, n)) unless n.nil?
			end
		body = body.gsub(/^([\w\-]+)?\:/,'<b style="color:#999;font-weight:bold;margin-right:5px">\1</b>')
			body
	end
end
