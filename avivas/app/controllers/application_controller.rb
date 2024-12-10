class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_categories

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_path, alert: "Lo sentimos, no tienes permiso para realizar esta acción." }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :telephone, :role, :entered_at ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :telephone, :role, :entered_at ])
  end

  def load_categories
    @side_categories = Category.order(name: :asc).limit(5)
  end
end
