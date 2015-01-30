class LandingController < ApplicationController
  skip_filter :authenticate_admin!

  def index
    @poplus = false
    @signup_form = SignupForm.new if @poplus
    redirect_to dash_path if current_admin
  end

  def request_invitation
    @signup_form = SignupForm.new(params[:signup_form])
    @signup_form.deliver
    flash[:notice] = "Thanks! You should hear back from us very soon."
    redirect_to root_path
  end
end
