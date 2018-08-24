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

    mail = Mail.new
    mail.from = params[:from]
    mail.to = params[:to]
    mail.cc = params[:cc]
    mail.subject = params[:subject]

    text_part = Mail::Part.new
    text_part.body = params[:text]

    html_part = Mail::Part.new
    html_part.body = simple_format(params[:text])

    mail.text_part = text_part
    mail.html_part = html_part

    MailWorker.perform_async(mail.to, Base64.encode64(mail.to_s), app.id)

    flash[:notice] = "Test email sent"
    redirect_to deliveries_url
  end
end
