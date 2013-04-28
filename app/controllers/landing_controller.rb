class LandingController < ApplicationController
  skip_filter :authenticate_admin!

  def index
  end
end
