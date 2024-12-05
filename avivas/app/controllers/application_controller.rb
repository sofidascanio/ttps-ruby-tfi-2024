class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_categories

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :telephone, :role, :entered_at])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :telephone, :role, :entered_at])
  end

  def load_categories
    @categories = Category.order(created_at: :desc).page(params[:page])
  end
end
