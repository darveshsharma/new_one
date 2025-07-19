class ApplicationController < ActionController::Base
 before_action :configure_permitted_parameters, if: :devise_controller?
 layout :layout_by_resource


 # Include Devise helpers in all controllers
 include Devise::Controllers::Helpers


 protected


 def configure_permitted_parameters
   devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :member])
 end


 def require_active_member
   unless user_signed_in? && current_user.member?
     redirect_to membership_payments_path, alert: "Please become a member to access this page."
   end
 end


 private


 def layout_by_resource
   if devise_controller?
     "application" # or a specific devise layout if styled differently
   else
     "application"
   end
 end
end
