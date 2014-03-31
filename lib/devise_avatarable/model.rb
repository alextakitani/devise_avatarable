module Devise
  module Models
    module Avatarable
      extend ActiveSupport::Concern

      included do
        # Mounting the uploaders and adding the versions that are configured for
        # +avatar_versions+ in the devise initializer.
        Devise.avatar_versions.each do |attribute, options|
          mount_uploader attribute, DeviseAvatarable::Uploader.get_uploader(self.name, attribute, options)
          attr_accessor "#{attribute}_crop"
        end

        after_update :crop_avatars
      end

      private
        # Check for each configured avatar if crop parameters are present
        # and if so recreate the avatar versions.
        def crop_avatars
          Devise.avatar_versions.each do |attribute,options|
            self.send(attribute).recreate_versions! if self.send("#{attribute}_crop").present?
          end
        end
    end
  end
end

