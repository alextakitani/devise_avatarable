module DeviseAvatarable
  module Generators
    class InstallGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      desc "Add DeviseAvatarable module, add config options to the Devise initializer and include assets in your application."

      argument :name, type: :string, default: "User", desc: "The Devise model this module should be added to.", banner: "NAME"
      class_option :initializer, type: :string, default: 'config/initializers/devise.rb', desc: 'Specify the Devise initializer path.', banner: 'PATH'

      def add_module
        path = File.join("app", "models", "#{file_path}.rb")
        if File.exists?(path)
          inject_into_file(path, "avatarable, :", :after => "devise :")
        else
          say_status "error", "Model not found. Expected to be #{path}.", :red
        end
      end

      def add_config_options_to_initializer
        initializer = options['initializer']

        if File.exist?(initializer)
          old_content = File.read(initializer)

          unless old_content.match(Regexp.new(/^\s# ==> Configuration for :avatarable\n/))
            inject_into_file(initializer, :before => "  # ==> Configuration for :confirmable\n") do
<<-CONTENT
  # ==> Configuration for :avatarable
  # Avatars are added by calling "config.avatar" with either just the name
  # of the avatar or by a configuration hash. You can use "config.avatar"
  # more then once to add multiple avatars to your Devise model. Don't forget to
  # create a migration too. Check the README on how it works exactly.
  # config.avatar :avatar

  # By default uploaded files are stored in the local file system under "/public/uploads".
  # You can configure other storage location by supplying a configuration hash here.
  # config.avatar_storage = {
  #   fog_credentials: {
  #     provider: 'AWS',
  #     aws_access_key_id: 'your_aws_access_key_id',
  #     aws_secret_access_key: 'your_aws_secret_access_key'
  #   },
  #   fog_directory: 'name_of_your_bucket'
  # }

CONTENT
            end
          end
        end
      end

      def require_javascripts
        insert_into_file "app/assets/javascripts/application#{detect_js_format[0]}",
          "#{detect_js_format[1]} require devise_avatarable\n", :after => "jquery_ujs\n"
      end

      def require_stylsheets
        insert_into_file "app/assets/stylesheets/application#{detect_css_format[0]}",
          " *= require devise_avatarable\n", :before => "*/"
      end

      private
        # Taken from
        # https://github.com/groundworkcss/groundworkcss-rails/blob/master/lib/groundworkcss/generators/install_generator.rb
        def detect_js_format
          return ['.js', '//='] if File.exist?('app/assets/javascripts/application.js')
          return ['.js.coffee', '#='] if File.exist?('app/assets/javascripts/application.js.coffee')
          return ['.coffee', '#='] if File.exist?('app/assets/javascripts/application.coffee')
          return false
        end

        def detect_css_format
          return ['.css'] if File.exist?('app/assets/stylesheets/application.css')
          return ['.css.sass'] if File.exist?('app/assets/stylesheets/application.css.sass')
          return ['.css.scss'] if File.exist?('app/assets/stylesheets/application.css.scss')
          return ['.sass'] if File.exist?('app/assets/stylesheets/application.sass')
          return ['.scss'] if File.exist?('app/assets/stylesheets/application.scss')
          return false
        end
    end
  end
end
