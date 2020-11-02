# frozen_string_literal: true

class LandingController < ApplicationController
  def index
    redirect_to dash_path if current_admin
  end
end
