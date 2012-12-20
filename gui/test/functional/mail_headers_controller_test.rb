require 'test_helper'

class MailHeadersControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => MailHeader.first
    assert_template 'show'
  end

  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    MailHeader.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    MailHeader.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to mail_header_url(assigns(:mail_header))
  end
  
  def test_edit
    get :edit, :id => MailHeader.first
    assert_template 'edit'
  end

  
  def test_update_invalid
    mail_header = MailHeader.first
    MailHeader.any_instance.stubs(:valid?).returns(false)
    put :update, :id => mail_header
    assert_template 'edit'
  end

  def test_update_valid
    mail_header = MailHeader.first
    MailHeader.any_instance.stubs(:valid?).returns(true)
    put :update, :id => mail_header
    assert_redirected_to mail_header_url(assigns(:mail_header))
  end

  
  def test_destroy
    mail_header = MailHeader.first
    delete :destroy, :id => mail_header
    assert_redirected_to mail_headers_url
    assert !MailHeader.exists?(mail_header.id)
  end
end
