class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  layout :set_layout
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def set_layout
    user_signed_in? ? "application" : "public"
  end
end
