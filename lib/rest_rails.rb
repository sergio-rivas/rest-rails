require "rest_rails/engine"
require "rest_rails/error"

module RestRails
  mattr_accessor :debug, default: false
  mattr_accessor :permit, default: :all
  mattr_accessor :authenticatable, default: false
  mattr_accessor :active_storage_attachments, default: true
  mattr_accessor :production_domain, default: nil
  mattr_accessor :development_domain, default: 'localhost:3000'

  def self.configure
    yield self
  end

  def self.path_for(ar_obj)
    root_path = RestRails::Engine.mounted_path
    table = ar_obj.class.table_name
    return "#{root_path}/#{table}" if ar_obj.id.nil?
    return "#{root_path}/#{table}/#{ar_obj.id}"
  end
end
