module Devise
  module Models
    module Avatarable
      extend ActiveSupport::Concern

      included do
        # Mounting the uploaders and adding the versions that are configured for
        # +avatar_versions+ in the devise initializer.
        # I'm not sure if this anonymous class is the best way of doing it but
        # because carrierwave methods like +version+ or +process+ work on the
        # singleton class I found no other way of creating different versions
        # for different instances of the uploader class.
        Devise.avatar_versions.each do |attribute,options|
          mount_uploader attribute, Class.new(DeviseAvatarable::BaseUploader) {
            process convert: options[:convert_to] unless options[:convert_to].is_a? FalseClass
            process resize_to_limit: options[:limit_to] unless options[:limit_to].is_a? FalseClass

            options[:versions].each do |name, args|
              opts = args.extract_options!
              method = opts[:process] || :resize_to_fill

              version name do
                process :crop
                process method => args
              end
            end
          }

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

