module DeviseAvatarable
  module Helpers
    #
    # This will create a image tag for the given avatar.
    #
    #   <%= devise_avatar_for @user %>
    #   => <img src="/uploads/user/avatar/1/small_avatar_1392976424.jpg" class="user-avatar">
    #
    # The parameters are
    #
    #   <%= devise_avatar_for [resource], [attribute=:avatar], [version=:default], options={} %>
    #
    def devise_avatar_for(*args)
      options = args.extract_options!
      resource = args.shift
      attribute = args.shift || :avatar
      version = args.shift || :default

      options[:class] ||= "#{resource.class.name.underscore.dasherize}-#{attribute.to_s}"

      image_tag resource.send(attribute).url(version), options
    end

    # Check if a avatar image is present
    #
    # <%= devise_avatar_present? [resource], [attribute=:avatar], options={} %>
    #
    def devise_avatar_present?(*args)
      options = args.extract_options!
      resource = args.shift
      attribute = args.shift || :avatar

      resource.send(attribute).file.present?
    end
  end
end
