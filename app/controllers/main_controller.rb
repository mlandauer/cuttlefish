class MainController < ApplicationController
  def index
    @no_emails_sent_today = Email.where('created_at > ?', Date.today.beginning_of_day).count
  end

  # Send a test email
  def test_email
    TestMailer.test.deliver
    flash[:notice] = "Test email sent"
    redirect_to :root
  end
end
