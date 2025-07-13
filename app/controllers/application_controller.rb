class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Include Devise helpers in all controllers
  include Devise::Controllers::Helpers

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end

  def require_active_member
  allowed_roles = ["member", "owner", "dealer"]
  unless user_signed_in? && current_user.role.in?(allowed_roles)
    redirect_to membership_path, alert: "Please become a member to access this page."
  end
end
end
