require File.dirname(__FILE__) + '/../spec_helper'

describe Post do 
	fixtures :post
	
	describe 'being_created' do 
		before do 
			@post = nil
			@creating_post = lambda do 
				@post = create_post
				violated "#{@post.errors.full_messages.to_sentence}" if @post.new_record?
			end
		end
		
		it "should have an author"
			
		end
		
		
	end
end