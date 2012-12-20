  context "GET to :edit" do
    setup do
      get :edit, :id => <%= get_fixture %>
    end
    should_assign_to :<%= singular_name %>
    should_respond_with :success
    should_render_template :edit
    should_not_set_the_flash
  end

