  def test_update_invalid
    <%= singular_name %> = <%= get_fixture %>
    <%= class_name %>.any_instance.stubs(:valid?).returns(false)
    put :update, :id => <%= singular_name %>
    assert_template 'edit'
  end

  def test_update_valid
    <%= singular_name %> = <%= get_fixture %>
    <%= class_name %>.any_instance.stubs(:valid?).returns(true)
    put :update, :id => <%= singular_name %>
    assert_redirected_to <%= item_path_for_test('url') %>
  end

