class Filter
	attr_reader :path, :service
	def initialize(service, path = nil)
		@path = path
		@service = service
	end
	
	def add(label,value = nil)
		Filter::Item.new(label,value, @path, @service)
	end
	
	class Item
		attr_reader :label, :value, :link
		def initialize(label, value, path, service)
			@label = label
			@value = value || label.downcase
			@link = "/current_section/according_to/#{service}?kind=#{@value.downcase}"
		end
		
	end

end