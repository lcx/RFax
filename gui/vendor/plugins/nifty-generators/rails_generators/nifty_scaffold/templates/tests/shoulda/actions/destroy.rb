  context "DELETE to :destroy" do
    setup do
      @<%= singular_name %> = <%= get_fixture %>
      delete :destroy, :id => @<%= singular_name %>
    end
    should_redirect_to ("<%= plural_name %> index") {<%= items_path('url') %>}
    should "destroy model" do
      assert !<%= class_name %>.exists?(@<%= singular_name %>.id)
    end
  end

