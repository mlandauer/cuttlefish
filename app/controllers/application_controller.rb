class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_admin!

  force_ssl :if => Proc.new{ force_ssl? }

  private

  # Don't use SSL for the TrackingController and in development
  def force_ssl?
   controller_name != "tracking" && !Rails.env.development? 
  end
end
