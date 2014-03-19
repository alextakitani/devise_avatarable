module DeviseAvatarable
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseAvatarable::UrlHelpers
      helper DeviseAvatarable::Helpers
    end
    ActiveSupport.on_load(:action_view) { include DeviseAvatarable::UrlHelpers }

    # We use to_prepare instead of after_initialize here because Devise is a
    # Rails engine and its classes are reloaded like the rest of the user's app.
    # Got to make sure that our methods are included each time.
    config.to_prepare do
      ActionView::Helpers::FormBuilder.send :include, DeviseAvatarable::FormHelpers
    end
  end
end
