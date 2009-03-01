require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController, "creating a new post" do 
	integrate_views
	fixtures [:posts, :comments]
	
	it "should redirect to the post on a succesful save" do
		Post.any_instance.stubs(:valid?).returns(true)
		post 'create'
		flash[:notice].should_not be_nil?
		response.should redirect_to(post_path)
	end
	
	
end