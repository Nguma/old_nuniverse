require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
	
	fixtures :users

	test "should be able to access account page if logged in" do
		login_as :quentin
		assert_redirected_to user_url(:quentin)
	end
end