# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :authenticate_admin!

  def index
    redirect_to dash_path if current_admin
  end
end
