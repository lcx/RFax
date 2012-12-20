  context "POST to :create" do
    context "when model is invalid" do
      setup do
        <%= class_name %>.any_instance.stubs(:valid?).returns(false)
        post :create
      end
      should_assign_to :<%= singular_name %>
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
    end
    context "when model is vaild" do
      setup do
        <%= class_name %>.any_instance.stubs(:valid?).returns(true)
        post :create
      end
      should_assign_to :<%= singular_name %>
      should_redirect_to("show <%= singular_name %> page") {<%= item_path_for_test('url') %>}
      should_set_the_flash_to "Successfully created <%= name.underscore.humanize.downcase %>."
    end
  end

