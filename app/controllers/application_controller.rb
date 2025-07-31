class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_profile_completion, if: :user_signed_in?

  layout :layout_by_resource

  # Include Devise helpers in all controllers
  include Devise::Controllers::Helpers

  protected

  # Allow additional fields during sign-up
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :member, :first_name, :last_name, :phone, :address])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :address])
  end

  # Redirect user if not an active member
  def require_active_member
    unless user_signed_in? && current_user.active_member?
      redirect_to membership_payments_path, alert: "Please become a member to access this page."
    end
  end

  # Redirect if profile is not completed
  def check_profile_completion
    if current_user && !current_user.profile_completed? && !on_profile_edit_page?
      redirect_to edit_profile_path, alert: "Please complete your profile before continuing."
    end
  end

  # Avoid infinite redirect loop
  def on_profile_edit_page?
    controller_name == "profiles" && action_name.in?(%w[edit update])
  end

  private

  def layout_by_resource
    if devise_controller?
      "application" # use custom devise layout if needed
    else
      "application"
    end
  end
end
