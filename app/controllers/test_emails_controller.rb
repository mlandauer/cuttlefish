class TestEmailsController < ApplicationController
  after_action :verify_authorized

  # We're using the simple_format helper below. Ugly but quick by bringing it into the controller
  include ActionView::Helpers::TextHelper

  def new
    authorize :test_email
    @to = current_admin.email_with_name
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
    authorize :test_email
    app = App.find(params[:app_id])
    authorize app, :show?

    # TODO: Handle errors
    CreateEmail.call(
      app_id: app.id,
      from: params[:from],
      to: params[:to],
      cc: params[:cc],
      subject: params[:subject],
      text_part: params[:text],
      html_part: simple_format(params[:text])
    )

    flash[:notice] = "Test email sent"
    redirect_to deliveries_url
  end
end
