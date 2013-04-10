class TestEmailsController < ApplicationController
  # We're using the simple_format helper below. Ugly but quick by bringing it into the controller
  include ActionView::Helpers::TextHelper

  # Send a test email
  def create
    mail = Mail.new
    mail.from = params[:from]
    mail.to = params[:to]
    mail.cc = params[:cc]
    mail.subject = params[:subject]
    mail.delivery_method :smtp, ActionMailer::Base.smtp_settings

    text_part = Mail::Part.new
    text_part.body = params[:text]

    html_part = Mail::Part.new
    html_part.content_type = 'text/html; charset=UTF-8'
    html_part.body = simple_format(params[:text])

    mail.text_part = text_part
    mail.html_part = html_part

    mail.deliver

    flash[:notice] = "Test email sent"
    redirect_to :root
  end
end