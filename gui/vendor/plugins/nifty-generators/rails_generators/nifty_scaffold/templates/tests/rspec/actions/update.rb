  it "update action should render edit template when model is invalid" do
    <%= singular_name %> = <%= get_fixture %>
    <%= class_name %>.any_instance.stubs(:valid?).returns(false)
    put :update, :id => <%= singular_name %>
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    <%= singular_name %> = <%= get_fixture %>
    <%= class_name %>.any_instance.stubs(:valid?).returns(true)
    put :update, :id => <%= singular_name %>
    response.should redirect_to(<%= item_path_for_spec('url') %>)
  end

