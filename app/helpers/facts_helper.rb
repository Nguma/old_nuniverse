module FactsHelper
	
	def render_fact(fact)

		fact.body_with_tag.gsub(/^([\w\-]+)\:/,'<b style="color:#999;font-weight:bold;margin-right:5px">\1</b>')
	end
end
