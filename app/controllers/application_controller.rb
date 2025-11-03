class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  #
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authonticate_user!
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :full_name, :avatar_image, :avatar_url ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name, :avatar_url, :avatar_image ])
  end

  def after_sign_in_path_for(resource)
    if  resource.admin?
      admin_dashboard_path
    else
      profile_path
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action"
    redirect_to(request.referrer || root_path)
  end
end
