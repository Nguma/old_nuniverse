class CreateController < ApplicationController

	before_filter :find_user
	
	before_filter :find_source
	

	def new
		
		@command = Command.new(:commander => current_user, :order => params[:order], :value => params[:value])
		@token = Token.new(str, :current_user => current_user)

			if @token
			 	if !@token.images.empty?
					@new = @token.images.first
				elsif !@token.bookmarks.empty?
					@new = @token.bookmarks.first
				elsif @token.value.is_a?(Comment)
					@source.comments << @token.value
					@new = @token.value
				elsif @token.value
					@source.nuniverses << @token.value rescue nil
					@new = @token.value
				elsif !@token.body.blank?
					@source.facts << @fact 
					@new = @fact
				end
				if @new
					@connection = @source.connections.with_subject(@new).first
					@connection.tags << @token.tags rescue nil
				end

				@tag = nil
			end
		@elements = Token.extract_urls(params[:value])
		raise @elements.images.inspect
		@source.images << @elements.images 

	end
	
	def comment
		@comment = Comment.create(params[:value], :user_id => current_user.id)
		@source.comments << @comment
		respond_to do |f|
			format.html {}
			format.js {}
		end
	end
	
	def review
	end
	
	def ranking
	end
	
	def tag
		
	end
	
	def connection
		@fact = Fact.create(:body => params[:value], :user_id => current_user.id, :parent_type => @source.type, :parent_id => @source.id)
		@connection = Polyco.find_or_create(:subject => @fact, :object => @source)
		@connection.tags << params[:order]
	end

	
	

end