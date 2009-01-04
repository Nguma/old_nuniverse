require File.dirname(__FILE__) + '/../test_helper'

class NuniversesControllerTest < ActionController::TestCase
	def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:nuniverses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
end