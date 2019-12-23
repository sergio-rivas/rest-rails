require "rest_rails/engine"

module RestRails
  mattr_accessor :debug, default: false
  mattr_accessor :authenticatable, default: false
  mattr_accessor :active_storage_attachments, default: true
  mattr_accessor :domain, default: 'localhost:3000'

  def self.configure
    yield self
  end
end
