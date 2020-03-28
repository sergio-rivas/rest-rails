module RestRails
  class Engine < ::Rails::Engine
    isolate_namespace RestRails

    def self.mounted_path
      route = Rails.application.routes.routes.detect do |route|
        self.in?([route.app, route.app.app])
      end
      route && route.path
    end
  end
end
