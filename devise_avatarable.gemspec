$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "devise_avatarable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "devise_avatarable"
  s.version     = DeviseAvatarable::VERSION
  s.authors     = ["Kai Schneider"]
  s.email       = ["schneikai@gmail.com"]
  s.homepage    = "https://github.com/schneikai/devise_avatarable"
  s.summary     = "Add avatars to your Devise model."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "devise", "~> 3.0"
  s.add_dependency "sass-rails" # , "~> 4.0"
  s.add_dependency "carrierwave", "~> 0.9"
  s.add_dependency "fog", "~> 1.20"
  s.add_dependency "RMagick", "~> 2.13.2"
  s.add_dependency "remotipart", "~> 1.2"
  s.add_dependency "jcrop-rails-v2", "~> 0.9"

  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "sqlite3"
end
