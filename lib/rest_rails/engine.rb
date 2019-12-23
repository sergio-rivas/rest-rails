module RestRails
  class Engine < ::Rails::Engine
    isolate_namespace RestRails

    def self.mounted_path
      route = Rails.application.routes.routes.detect do |route|
        route.app == self
      end
      route && route.path
    end
  end
end
