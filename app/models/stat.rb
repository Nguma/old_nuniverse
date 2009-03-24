class Stat 
	
	attr_reader :value, :total, :score
	
	def initialize(params)
		@score = params[:score]
		@value = params[:value]
		@total = params[:total] || @value
	end
	

	
	def percent
		return '0%' if @total == 0
		"#{(@value * 100) / @total}%"
	end
end