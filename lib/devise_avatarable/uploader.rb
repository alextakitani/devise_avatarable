# encoding: utf-8

module DeviseAvatarable
  class Uploader < CarrierWave::Uploader::Base
    include CarrierWave::RMagick

    # Returns the uploader class for the given model name and avatar.
    # If a uploader class exists in the host application it is extended with the
    # processing options for the configured versions and returned.
    # For example if the model is called +User+ and the avatar +avatar+ the name
    # of your uploader class must be +UserAvatarUploader+.
    # If no avatar uploader exists in the host application a anonymouse uploader
    # class is created and returned.
    # I'm not sure if this anonymous class is the best way of doing it but
    # because carrierwave methods like +version+ or +process+ work on the
    # singleton class I found no other way of creating different versions
    # for different instances of the uploader class.
    def self.get_uploader(class_name, avatar_name, options)
      name = "#{class_name.to_s.classify}#{avatar_name.to_s.classify}Uploader"

      uploader = name.safe_constantize || Class.new(self)

      uploader.class_eval do
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
      end

      uploader
    end

    # Load our carrierwave configuration. This way we can keep it
    # in the engine and won't mess up global carrierwave configuration.
    def initialize(*)
      super

      if Devise.avatar_storage.is_a?(Hash)
        store = :fog
        Devise.avatar_storage.each do |k,v|
          self.send "#{k}=", v
        end
      else
        store = Devise.avatar_storage
      end

      @storage = self.storage_engines[store].constantize.new(self)
    end

    # Image processing methods and versions are added dynamically
    # in *model.rb* from the avatar configuration.

    # This is the version we use as a preview in the editor.
    version :editor_preview do
      process :crop
      process :editor_preview
    end


    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    # Returns a default URL if no file was uploaded.
    # To create default images check the README under "Generating default images".
    def default_url
      ActionController::Base.helpers.asset_path(default_name(version_name))
    end

    # Returns the name of the default image.
    def default_name(version)
      [model.class.to_s.underscore, mounted_as, version, 'default.jpg'].compact.join('_')
    end

    # Add a white list of extensions which are allowed to be uploaded.
    # For images you might use something like this:
    def extension_white_list
      %w(jpg jpeg gif png)
    end

    # # Override the filename of the uploaded files:
    # # Avoid using model.id or version_name here, see uploader/store.rb for details.
    # def filename
    #   "something.jpg" if original_filename
    # end

    def filename
      @name ||= "#{mounted_as}_#{timestamp}.jpg" if original_filename
    end

    # Overwrite recreate version and make it save the new file names to the database
    # and delete the previous files.
    #
    # It took me some time to figure out what was going on so here are some findings:
    #
    # When a file is uploaded original_filename has the name of the uploaded file.
    # When no file is uploaded but recreate_versions! is called original_filename
    # is nil on the first call to filename but on later calls it magically has a value.
    # It has something todo with cache! downloading the file from the storage
    # and assigning it so as if it was just uploaded.
    #
    # Using random filenames and recreate_versions! would create new files
    # without deleting the previous files.

    def recreate_versions!
      previous_model = model.send("find_previous_model_for_#{mounted_as}")
      super
      model.update_column mounted_as, model.send(mounted_as).filename
      if previous_model && previous_model.send(mounted_as).path != model.send(mounted_as).path
        previous_model.send(mounted_as).remove!
      end
    end

    # Returns the size of the image in the editor by reading it from the avatar settings.
    def editor_size
      Devise.avatar_versions[mounted_as][:editor_size]
    end

    private
      def timestamp
        var = :"@#{mounted_as}_timestamp"
        model.instance_variable_get(var) or model.instance_variable_set(var, Time.now.to_i)
      end

      # Create the editor preview version.
      def editor_preview
        resize_to_fit editor_size, editor_size
      end

      # Create the crop.
      def crop
        crop = model.send "#{mounted_as}_crop"

        if crop.present?
          manipulate! do |img|
            # jCrop works on a smaller image and we need
            # to scale the coordinates to match the real image size.
            scale = [img.columns, img.rows].max / (0.0 + editor_size)
            img.crop! *(crop.split(',').map {|v| v.to_i * scale})
          end
        end
      end
  end
end
