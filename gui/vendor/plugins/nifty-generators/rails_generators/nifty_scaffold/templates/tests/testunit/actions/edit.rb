  def test_edit
    get :edit, :id => <%= get_fixture %>
    assert_template 'edit'
  end

