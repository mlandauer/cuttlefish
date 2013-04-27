class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_admin!

  # Don't use SSL for the TrackingController and in development
  force_ssl :unless => Proc.new{
    controller_name == "tracking" || Rails.env.development?
  }
end
