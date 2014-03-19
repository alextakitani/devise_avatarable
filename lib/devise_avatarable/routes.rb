module ActionDispatch::Routing
  class Mapper
    protected
      def devise_avatar(mapping, controllers)
        #
        # This will create routes for each configured avatar. For example if the
        # avatar is named *cover* this would create the following routes:
        #
        #   edit_user_cover_path  GET      /users/cover/edit(.:format)  devise/avatars#edit
        #   user_cover_path       PATCH   /users/cover(.:format)        devise/avatars#update
        #
        Devise.avatar_versions.each do |attribute, options|
          resource attribute, only: [:edit, :update], path: mapping.path_names[attribute], controller: controllers[:avatars], attribute: attribute
        end
      end
  end
end
