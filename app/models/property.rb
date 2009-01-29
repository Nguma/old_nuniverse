class Property
	attr_accessor :label, :value
	
	def initialize(params)
		@label = params[:label]
		@value = params[:value]
	end
end