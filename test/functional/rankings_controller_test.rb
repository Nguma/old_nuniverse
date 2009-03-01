# require 'test_helper'
# 
# class RankingsControllerTest < ActionController::TestCase
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:rankings)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
# 
#   def test_should_create_rankings
#     assert_difference('Rankings.count') do
#       post :create, :rankings => { }
#     end
# 
#     assert_redirected_to rankings_path(assigns(:rankings))
#   end
# 
#   def test_should_show_rankings
#     get :show, :id => rankings(:one).id
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => rankings(:one).id
#     assert_response :success
#   end
# 
#   def test_should_update_rankings
#     put :update, :id => rankings(:one).id, :rankings => { }
#     assert_redirected_to rankings_path(assigns(:rankings))
#   end
# 
#   def test_should_destroy_rankings
#     assert_difference('Rankings.count', -1) do
#       delete :destroy, :id => rankings(:one).id
#     end
# 
#     assert_redirected_to rankings_path
#   end
# end
