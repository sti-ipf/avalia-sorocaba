require 'test_helper'

class ServiceLevelsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_levels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_level" do
    assert_difference('ServiceLevel.count') do
      post :create, :service_level => { }
    end

    assert_redirected_to service_level_path(assigns(:service_level))
  end

  test "should show service_level" do
    get :show, :id => service_levels(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => service_levels(:one).to_param
    assert_response :success
  end

  test "should update service_level" do
    put :update, :id => service_levels(:one).to_param, :service_level => { }
    assert_redirected_to service_level_path(assigns(:service_level))
  end

  test "should destroy service_level" do
    assert_difference('ServiceLevel.count', -1) do
      delete :destroy, :id => service_levels(:one).to_param
    end

    assert_redirected_to service_levels_path
  end
end
