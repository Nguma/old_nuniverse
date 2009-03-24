class Command
	attr_accessor :order, :value, :author, :tag
	
	def initialize(params)
		@commander = params[:commander]
		@order = params[:order]
		@value = params[:value]
		@tag = Tag.find_or_create(:name => @order)
	end
	
	def interpret
		case @order
		when /^add\s.*/,'':
		when /^invite\s/
		else
		end
	end
	

end