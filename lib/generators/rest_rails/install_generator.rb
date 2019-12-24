# frozen_string_literal: true

module RestRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      namespace "rest_rails:install"
      source_root File.expand_path('../templates', __FILE__)
      # argument :name, :type => :string, :default => "en"
      def basic_setup
        # Setup Initializer
        template "rest_rails.rb", "config/initializers/rest_rails.rb"
      end
      def setup_routes
        route "mount RestRails::Engine => '/api/v1', as: 'rest'"
        route "# For more information, check out the gem repo: https://github.com/sergio-rivas/rest-rails"
        route "# Note: Make sure RestRails engine is at the BOTTOM of routes"
        route "# RestRails standard REST API for all models"
      end
      def completed
        readme "README"
      end
    end
  end
end
