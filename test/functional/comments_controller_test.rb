require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
	
	fixtures :all
	def setup
	 login_as :quentin
	end
	

	test "should create a comment, assign the current user as author and redirect to post" do
		
		p = Post.create!(:title => "Hello", :body => "World")
		post :create, :post_id => p.id, :comment => {:body => "nice"}
		assert_equal :quentin, p.comments.first.author
		assert_redirected_to post_url(p)
		assert_equal "nice", p.comments.first.body
	end 
end
