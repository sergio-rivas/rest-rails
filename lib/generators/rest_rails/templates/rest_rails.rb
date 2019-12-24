# Here's the configuration setup for RestRails!

RestRails.configure do |config|
  # set debug to true if you want to see loud errors in the server logs.
  config.debug = false

  # ===============================================================
  #                       IMPORTANT!
  #    Setup whitelist permissions for what db columns can be
  #      modified by the REST API
  # ===============================================================
  # config.permit = {
  #  users: :none,
  #  table_name: :all,
  #  other_table: [:col1, :col2, :col3]
  # }

  # ===============================================================
  # if you are using devise or another authentication system and want to
  # enforce the before_action `authenticate_user!`
  #
  # Note: take a look at `simple_token_authentication` or `tiddle` gems to setup
  # token-based authentication for devise.
  config.authenticatable = false


  # ===============================================
  #       ACTIVE STORAGE SETTINGS FOR ATTACHMENTS
  # ===============================================
  # to enable REST attachments via active storage
  config.active_storage_attachments = false

  # to setup domains to attach to urls returned from activestorage blob_url.
  # if used for WEB, you can simply put "/"
  # if using for Native Apps, or WeChat/AliPay Mini Programs,
  # you should have this be the domain of your API host. e.g.: 'https://api.fakeurl.com'
  config.production_domain = nil

  # Set development domain if needed.
  config.development_domain = "http://localhost:3000"
end
