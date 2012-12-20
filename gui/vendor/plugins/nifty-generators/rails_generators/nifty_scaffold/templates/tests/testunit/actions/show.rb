  def test_show
    get :show, :id => <%= get_fixture %>
    assert_template 'show'
  end

