class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_trips # dans private

  protected

  def configure_permitted_parameters
    # Pour le sign up
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # Pour l'édition de compte
    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

private

  def set_trips # permet de définir trips pour toutes les pages, ici je l'ai mis pour que la sidebar soit sur toutes les pages
    @trips = current_user&.trips
  end

end
