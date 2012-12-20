require 'test_helper'

class DidsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Did.first
    assert_template 'show'
  end

  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Did.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Did.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to did_url(assigns(:did))
  end
  
  def test_edit
    get :edit, :id => Did.first
    assert_template 'edit'
  end

  
  def test_update_invalid
    did = Did.first
    Did.any_instance.stubs(:valid?).returns(false)
    put :update, :id => did
    assert_template 'edit'
  end

  def test_update_valid
    did = Did.first
    Did.any_instance.stubs(:valid?).returns(true)
    put :update, :id => did
    assert_redirected_to did_url(assigns(:did))
  end

  
  def test_destroy
    did = Did.first
    delete :destroy, :id => did
    assert_redirected_to dids_url
    assert !Did.exists?(did.id)
  end
end
