require 'test_helper'

class FaxesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Fax.first
    assert_template 'show'
  end

  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Fax.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Fax.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to fax_url(assigns(:fax))
  end
  
  def test_edit
    get :edit, :id => Fax.first
    assert_template 'edit'
  end

  
  def test_update_invalid
    fax = Fax.first
    Fax.any_instance.stubs(:valid?).returns(false)
    put :update, :id => fax
    assert_template 'edit'
  end

  def test_update_valid
    fax = Fax.first
    Fax.any_instance.stubs(:valid?).returns(true)
    put :update, :id => fax
    assert_redirected_to fax_url(assigns(:fax))
  end

  
  def test_destroy
    fax = Fax.first
    delete :destroy, :id => fax
    assert_redirected_to faxes_url
    assert !Fax.exists?(fax.id)
  end
end
