module DeviseAvatarable
  class DefaultImageGenerator
    attr_accessor :options
    attr_accessor :model
    attr_accessor :attribute

    def initialize(*args)
      @options = args.extract_options!
      @model = args.shift
      @attribute = args.shift
    end

    # Generate default images for all configured avatars or a specified avatar.
    #
    # To generate a generic default image for all configured avatars use
    #   DefaultImageGenerator.generate
    #
    # To generate a generic default avatar image for a model *User* and a
    # attribute *avatar* use
    #   DefaultImageGenerator.generate(:user, :avatar)
    #
    # To generate a default avatar from a given image use
    #   DefaultImageGenerator.generate(:user, :avatar, file: 'path/to/file.jpg')
    #
    # Make sure the file you specify fits the dimensions you have specified
    # for the avatar. That means it must be large enough and the aspect ratio must fit.
    #
    def self.generate(*args)
      options = args.extract_options!

      if args.empty?
        # TODO: This is probably to simple but works for Hive.
        # For Devise though there can be multiple mappings for different models.
        model = Devise.mappings.first.first

        Devise.avatar_versions.each do |attribute, attribute_options|
          DefaultImageGenerator.new(model, attribute, options).send :generate
        end
      else
        DefaultImageGenerator.new(*(args << options)).send :generate
      end
    end

    private
      def generate
        versions = Devise.avatar_versions[self.attribute][:versions]

        # Need to add the "editor_preview" version from BaseUploader too.
        versions[:editor_preview] = [uploader.editor_size, uploader.editor_size]

        versions.each do |version, size|
          if self.options[:file].present?
            generate_from_file self.options[:file], size, file_path(version)
          else
            generate_generic_image size, (self.options[:color] || 'grey'), file_path(version)
          end
          puts "Created #{self.attribute}:#{version} in #{file_path(version)}."
        end
      end

      # Generates a simple image file of the specified size with a grey
      # background and saves it to the given path.
      def generate_generic_image(size, color, save_to)
        image = Magick::Image.new(*size) {
          self.background_color = color
        }
        image.write(save_to)
      end

      # Resizes a given image to the specified size with and saves it to
      # the given path.
      def generate_from_file(file, size, save_to)
        image = Magick::Image.read(file).first
        image.resize!(*size)
        image.write(save_to)
      end

      # Returns a absolut path with file name where to save the
      # generated default image. This must be your applications asset directory because
      # the default image is rendered in the template via the *asset_path* helper.
      #
      #    self.file_path(:small)
      #    => /path/to/rails/app/assets/images/user_avatar_small_default.jpg
      #
      def file_path(version)
        # TODO:  In the uploader we use "ActionController::Base.helpers.asset_path" to create
        # the "default_url". Why not here?
        Rails.root.join('app', 'assets', 'images', file_name(version))
      end

      # Returns the file name of the default image.
      # This uses the mounted uploaders method *default_name*.
      def file_name(version)
        uploader.default_name(version)
      end

      # Returns the uplaoder for the current model and attribute.
      def uploader
        @uploader ||= self.model.to_s.classify.constantize.new.send(self.attribute)
      end
  end
end
