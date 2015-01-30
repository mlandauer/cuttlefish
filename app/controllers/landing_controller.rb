class LandingController < ApplicationController
  skip_filter :authenticate_admin!

  def index
    @poplus = false
    @signup_form = SignupForm.new if @poplus
    redirect_to dash_path if current_admin
  end
end
