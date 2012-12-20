  it "edit action should render edit template" do
    get :edit, :id => <%= get_fixture %>
    response.should render_template(:edit)
  end

