class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_admin!

  # Don't use SSL for the DeliveriesController and only in production
  force_ssl :if => Proc.new{
    controller_name != "deliveries" && Rails.env.production?
  }
end
