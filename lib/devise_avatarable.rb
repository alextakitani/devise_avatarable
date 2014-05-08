require 'devise'
require 'remotipart'
require 'jcrop/rails/v2'
require 'carrierwave'
require 'devise_avatarable/routes'
require 'devise_avatarable/devise'

module DeviseAvatarable
  autoload :AvatarDefaults, 'devise_avatarable/avatar_defaults'
  autoload :Uploader, 'devise_avatarable/uploader'
  autoload :Helpers, 'devise_avatarable/helpers'
  autoload :FormHelpers, 'devise_avatarable/form_helpers'
  autoload :UrlHelpers, 'devise_avatarable/url_helpers'
  autoload :DefaultImageGenerator, 'devise_avatarable/default_image_generator'
  autoload :VERSION, 'devise_avatarable/version'
end

require 'devise_avatarable/engine'
