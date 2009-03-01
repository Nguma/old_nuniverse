class Parser
	
	attr_accessor :file, :doc
	
	def initialize(file)
		@file = file
	end
	
	def read
		@doc = Hpricot::XML(File.read(@file))
		@doc
	end
	
	def write(xml)
		File.open(@file, 'w') do |f|
			f.puts(xml)
		end
	end
end