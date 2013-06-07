class TestEmailsController < ApplicationController
  # We're using the simple_format helper below. Ugly but quick by bringing it into the controller
  include ActionView::Helpers::TextHelper

  def new
    @from = "contact@openaustraliafoundation.org.au"
    @to = "Matthew Landauer <matthew@openaustralia.org>"
    @subject = "This is a test email from Cuttlefish"
    @text = <<-EOF
Hello folks. Hopefully this should have worked and you should
be reading this. So, all is good.

Love,
The Awesome Cuttlefish
<a href="http://cuttlefish.io">http://cuttlefish.io</a>
    EOF
  end

  # Send a test email
  def create
    TestMailer.test_email(params[:app_id] ? App.find(params[:app_id]) : App.cuttlefish,
      from: params[:from], to: params[:to], cc: params[:cc], subject: params[:subject], text: params[:text]).deliver

    flash[:notice] = "Test email sent"
    redirect_to new_test_email_path
  end
end