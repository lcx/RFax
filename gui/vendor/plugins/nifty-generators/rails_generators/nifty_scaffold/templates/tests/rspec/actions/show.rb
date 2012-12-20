  it "show action should render show template" do
    get :show, :id => <%= get_fixture %>
    response.should render_template(:show)
  end

