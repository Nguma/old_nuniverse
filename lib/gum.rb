class Gum
	protected
	
	def self.parse(data)
		data.scan(/\s*\[?(#([\w_]+)\s+([^#|\[\]]+))\]?/)
	end
	
	def self.purify(data)
		data.strip
	end
end