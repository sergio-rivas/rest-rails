module RestRails
  class ApplicationController < ActionController::API
    before_action :authenticate_user!, if: -> {self.respond_to?("authenticate_user!") && RestRails.authenticatable}
    before_action :set_locale

    rescue_from StandardError, with: :internal_server_error
    rescue_from RestRails::Error, with: :internal_server_error
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def verify_authenticity_token
      true
    end

    def not_found(exception)
      if RestRails.debug
        raise exception
      else
        render json: { error: exception.message }, status: :not_found
      end
    end

    def internal_server_error(exception)
      if RestRails.debug
        raise exception
      elsif Rails.env.development?
        response = { type: exception.class.to_s, error: exception.message }
      else
        response = { error: "Internal Server Error" }
      end
      render json: response, status: :internal_server_error
    end

    def set_locale
      I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
      session[:locale] = I18n.locale
    end
  end
end
