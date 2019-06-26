module Plankbot
  class InitializerGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def copy_initializer_file
      copy_file "plankbot_check_and_notify.rb", "config/initializers/plankbot_check_and_notify.rb"
    end
  end
end
