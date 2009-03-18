class Command
	attr_accessor :order, :value, :author
	
	def initialize(params)
		@commander = params[:commander]
		@order = params[:order]
		@value = params[:value]
	end
	
	def interpret
		case @order
		when /^add\s.*/,'':
		when /^invite\s/
		else
		end
	end
	

end