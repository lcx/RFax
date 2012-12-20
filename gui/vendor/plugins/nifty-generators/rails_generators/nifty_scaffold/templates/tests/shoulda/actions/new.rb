  context "GET to :new" do
    setup do
      get :new
    end
    should_assign_to :<%= singular_name %>
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end

