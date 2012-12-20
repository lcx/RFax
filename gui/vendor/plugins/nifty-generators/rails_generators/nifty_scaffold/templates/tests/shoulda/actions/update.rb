  context "PUT to :update" do
    context "when model is invalid" do
      setup do
        <%= singular_name %> = <%= get_fixture %>
        <%= class_name %>.any_instance.stubs(:valid?).returns(false)
        put :update, :id => <%= singular_name %>
      end
      should_assign_to :<%= singular_name %>
      should_respond_with :success
      should_render_template :edit
      should_not_set_the_flash
    end
    context "when model is vaild" do
      setup do
        <%= singular_name %> = <%= get_fixture %>
        <%= class_name %>.any_instance.stubs(:valid?).returns(true)
        put :update, :id => <%= singular_name %>
      end
      should_assign_to :<%= singular_name %>
      should_redirect_to("show <%= singular_name %> page") {<%= item_path_for_test('url') %>}
      should_set_the_flash_to "Successfully updated <%= name.underscore.humanize.downcase %>."
    end
  end

