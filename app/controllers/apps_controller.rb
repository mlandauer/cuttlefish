class AppsController < ApplicationController
  def index
  end

  def new
    # TODO Extract this
    @default_open_tracking_domain = Rails.configuration.action_mailer.default_url_options[:host]
  end
end