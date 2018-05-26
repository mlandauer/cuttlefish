class LandingController < ApplicationController
  skip_filter :authenticate_admin!

  def index
    # Ugly hack to show a special version of the page on cuttlefish.oaf.org.au
    # Disabled now that it's not being funded by the grant and we're not offering accounts
    # TODO: Remove this sign up code
    # @poplus = (request.domain(3) == "cuttlefish.oaf.org.au")
    # @signup_form = SignupForm.new if @poplus
    redirect_to dash_path if current_admin
  end

  def request_invitation
    @signup_form = SignupForm.new(params[:signup_form])
    @signup_form.deliver
    flash[:notice] = "Thanks! You should hear back from us very soon."
    redirect_to root_url
  end
end
