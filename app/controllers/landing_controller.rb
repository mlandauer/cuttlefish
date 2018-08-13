class LandingController < ApplicationController
  skip_filter :authenticate_admin!

  def index
    redirect_to dash_path if current_admin
  end
end
