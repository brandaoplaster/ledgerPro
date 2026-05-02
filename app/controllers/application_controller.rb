class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout :set_layout

  allow_browser versions: :modern

  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def set_layout
    user_signed_in? ? "application" : "public"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
