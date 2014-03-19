module Devise
  # Configure the avatar. To add a avatar named "avatar" with default options use
  #
  #   config.avatar :avatar
  #
  # This will create a avatar with a default size of 200x200px.
  #
  # To add a(nother) avatar with a specific size use
  #
  #   config.avatar :cover, [1024, 200]
  #
  # And finally a example avatar with all available configuration options
  #
  #   config.avatar :avatar,
  #     limit_to: [800, 800],
  #     convert_to: :png,
  #     editor_size: 400,
  #     aspect_ratio: 16/9.0,
  #     versions: {
  #       mini: [50, 50],
  #       feed: [150, 150, { process: :resize_to_fill }],
  #       profile: [500, 500, { process: :resize_to_fit }],
  #       ...
  #     }
  #
  # Check the README under "Configure avatars" for a walkthrough of all options.
  #
  def self.avatar(*args)
    options = args.extract_options!
    name = args.shift
    default_size = args.shift

    # Add defaults
    options[:limit_to] ||= DeviseAvatarable::AvatarDefaults.limit_to
    options[:convert_to] ||= DeviseAvatarable::AvatarDefaults.convert_to
    options[:editor_size] ||= DeviseAvatarable::AvatarDefaults.editor_size
    options[:versions] ||= DeviseAvatarable::AvatarDefaults.version(default_size)
    options[:aspect_ratio] ||= DeviseAvatarable::AvatarDefaults.aspect_ratio(name, options[:versions])

    @@avatar_versions[name] = options
  end

  mattr_reader :avatar_versions
  @@avatar_versions = {}

  # Configure the storage location. Defaults to :file that will save uploaded
  # files to the local file sytem under [app_root]/public/uploads.
  # You can canfigure it to use Amazon S3, Rackspace, Google Storage or
  # other by supplying a configuration hash. Please check the readme for available options.
  mattr_accessor :avatar_storage
  @@avatar_storage = :file
end

Devise.add_module :avatarable, controller: :avatar, model: 'devise_avatarable/model', route: :avatar
