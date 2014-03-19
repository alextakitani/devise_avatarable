# Create default images for avatars
#
# To generate a generic default image for all configured avatars use
#   bundle exec rake devise_avatarable_create_defaults
#
# To generate a generic default image for a specific avatar named *avatar*
#   bundle exec rake devise_avatarable_create_defaults avatar=avatar
#
# To generate default images for a specific avatar named *avatar* from a given image use
#   bundle exec rake devise_avatarable_create_defaults avatar=avatar file=path/to/file.jpg

desc "Create default images for avatars"
task :devise_avatarable_create_defaults => :environment do
  model = (ENV['model'] || :user).to_sym
  attribute = (ENV['avatar'] || :all).to_sym

  options = {}
  options[:file] = ENV['file'] if ENV['file'].present?
  options[:color] = ENV['color'] if ENV['color'].present?

  if attribute == :all
    DeviseAvatarable::DefaultImageGenerator.generate(options)
  else
    DeviseAvatarable::DefaultImageGenerator.generate(model, attribute, options)
  end
end
