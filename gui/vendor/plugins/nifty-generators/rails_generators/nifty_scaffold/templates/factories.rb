<%= original -%>
Factory.define :<%= singular_name %> do |<%= singular_name.first %>|
<%- for attribute in attributes -%>
  <%= singular_name.first %>.<%= attribute.name %> '<%= attribute.default %>'
<%- end -%>
end

