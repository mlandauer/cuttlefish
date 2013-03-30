class MainController < ApplicationController
  def index
  end

  # Send a test email
  def test_email
    TestMailer.test.deliver
    flash[:notice] = "Test email sent"
    redirect_to :root
  end
end
