module DeviseAvatarable
  # Create url helpers to be used with resource/scope configuration. Acts as
  # proxies to the generated routes created by devise.
  # Resource param can be a string or symbol, a class, or an instance object.
  module UrlHelpers
    [:path, :url].each do |path_or_url|
      [nil, :edit_].each do |action|
        class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
          def #{action}avatar_#{path_or_url}(resource, *args)
            resource = case resource
              when Symbol, String
                resource
              when Class
                resource.name.underscore
              else
                resource.class.name.underscore
            end

            send("#{action}\#{resource}_avatar_#{path_or_url}", *args)
          end
        URL_HELPERS
      end
    end
  end
end
