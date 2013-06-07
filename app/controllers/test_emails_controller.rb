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
    mail = Mail.new
    mail.from = params[:from]
    mail.to = params[:to]
    mail.cc = params[:cc]
    mail.subject = params[:subject]
    # Send our own outgoing email through Cuttlefish
    # TODO: Move this configuration into the base class of Cuttlefish mailers
    if params[:app_id]
      app = App.find(params[:app_id])
    else
      app = App.cuttlefish
    end

    # This nasty hack is here to make this sensibly testable
    # TODO Refactor this whole action to use normal rails mailers
    if Rails.env.test?
      mail.delivery_method :test
    else
      mail.delivery_method :smtp, {
        address: "localhost",
        port: Rails.configuration.cuttlefish_smtp_port,
        user_name: app.smtp_username,
        password: app.smtp_password,
        authentication: :plain
      }
    end
    text_part = Mail::Part.new
    text_part.body = params[:text]

    html_part = Mail::Part.new
    html_part.content_type = 'text/html; charset=UTF-8'
    html_part.body = simple_format(params[:text])

    mail.text_part = text_part
    mail.html_part = html_part

    mail.deliver

    flash[:notice] = "Test email sent"
    redirect_to new_test_email_path
  end
end