module DeviseAvatarable
  module FormHelpers
    # Add the avatar editor to your form.
    # This will let your users select a image from their computer, upload it and
    # select a crop from it.
    #
    #   <%= form_for resource, as: resource_name, url: registration_path(resource_name) do |f| %>
    #     <%= f.avatar_editor :avatar %>
    #   <% end %>
    #
    def avatar_field(attribute, *args)
      options = args.extract_options!
      version_options = Devise.avatar_versions[attribute]

      options[:id] ||= "devise_avatarable_editor_#{object_name}_#{attribute}"
      options[:class] = "devise-avatarable-editor #{options[:class]}".strip

      # If the host app is using the TwitterBootstrapFormFor form builder the *class*
      # option will contain "form-control" which would make sense if we would have a simple
      # form field. But we don't so we remove the "form-control" class.
      options[:class].gsub!('form-control', '')
      options[:class].squish!

      # Some options actually need to be data attributes on the html element
      # we create later. So we setup defaults here and then we check if those
      # attributes exists as options and if yes overwrite the defaults.
      options[:data] ||= {}

      { resource: object_name,
        attribute: attribute,
        aspect_ratio: version_options[:aspect_ratio],
        url: @template.send("#{object_name}_#{attribute}_path")
      }.each do |attr,value|
        options[:data][attr] = options[:data][attr] || options.delete(attr) || value
      end

      @template.render partial: 'devise/avatars/editor', locals: { resource: @object, attribute: attribute, f: self, html_options: options }
    end
  end
end
