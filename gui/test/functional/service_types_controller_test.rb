require 'test_helper'

class ServiceTypesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => ServiceType.first
    assert_template 'show'
  end

  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    ServiceType.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    ServiceType.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to service_type_url(assigns(:service_type))
  end
  
  def test_edit
    get :edit, :id => ServiceType.first
    assert_template 'edit'
  end

  
  def test_update_invalid
    service_type = ServiceType.first
    ServiceType.any_instance.stubs(:valid?).returns(false)
    put :update, :id => service_type
    assert_template 'edit'
  end

  def test_update_valid
    service_type = ServiceType.first
    ServiceType.any_instance.stubs(:valid?).returns(true)
    put :update, :id => service_type
    assert_redirected_to service_type_url(assigns(:service_type))
  end

  
  def test_destroy
    service_type = ServiceType.first
    delete :destroy, :id => service_type
    assert_redirected_to service_types_url
    assert !ServiceType.exists?(service_type.id)
  end
end
