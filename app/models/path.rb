class Path
	attr_reader :str, :ar
	def initialize(str)
		@str = str
		@ar = []
		
		str.split('/').each_with_index do |n,i|
			if i == 0
				u = User.find_by_login(n.downcase)
				if u
					@ar << u
				else
					@ar << Nuniverse.find_or_create(:name => n) 
				end
			
			else
				# @ar << Nuniverse.find_or_create(:path => "\/#{@ar.collect {|c| c.name }.join('/')}\/", :name => n) unless n.blank?
				@ar << Tag.analyze(n)
			end
		end
	
	end
	
	def to_a
		@ar
	end
	
	
	def to_s
		"/#{@ar.collect{|c| c.unique_name}.join('/')}/"
	end
	
	def empty?
		return true if @ar.length <= 1
		return false
	end
	
	def last
		@ar.last
	end
	
	def first
		
		@ar.first
	end
end