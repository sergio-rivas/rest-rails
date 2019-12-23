Rails.application.routes.draw do
  mount RestRails::Engine => "/rest_rails"
end
