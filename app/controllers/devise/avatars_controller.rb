class Devise::AvatarsController < DeviseController
  respond_to :html, :js
  prepend_before_filter :authenticate_scope!

  # GET /resource/avatars/edit
  def edit
  end

  # PUT /resource/avatars
  def update
    if resource.update_attributes(attribute_params)
      # Reset the flag that is used to remove the current avatar or when we would
      # render a form this would tick the checkbox "remove avatar" again.
      resource.send("remove_#{attribute}=", nil)

      if attribute_params[attribute].present?
        render :crop
      else
        set_flash_message :notice, :updated if is_flashing_format?
        respond_with resource, location: after_update_path_for(resource)
      end
    else
      Rails.logger.error resource.errors
      respond_with_navigational(resource){ render :edit }
    end
  end

  protected
    # The default url to be used after updating the avatar. You need to
    # overwrite this method in your own AvatarsController.
    def after_update_path_for(resource)
      signed_in_root_path(resource)
    end

    # Authenticates the current scope and gets the current resource from the session.
    def authenticate_scope!
      send(:"authenticate_#{resource_name}!", :force => true)
      self.resource = send(:"current_#{resource_name}")
    end

    # Devise avatarable can have different avatars configured. For example you
    # can have a user with a avatar photo and a cover photo for the user profile.
    # This method returns the avatar to edit.
    # This is read from params[:attribute] and was set in the route:
    #   /users/avatar/edit
    #   /users/cover/edit
    def attribute
      params[:attribute].present? ? params[:attribute].to_sym : :avatar
    end
    helper_method :attribute

    # Permit the params for the avatar. For example if the avatar is named "avatar"
    # this would be: :avatar, :avatar_crop, :remove_avatar and :avatar_cache
    def attribute_params
      params.require(resource_name).permit(attribute, "#{attribute}_crop".to_sym, "remove_#{attribute}".to_sym, "#{attribute}_cache".to_sym)
    end

    # Returns true if the current avatar is to be deleted.
    def remove?
      attribute_params["remove_#{attribute}"].present? && attribute_params["remove_#{attribute}"] == '1'
    end
    helper_method :remove?
end

