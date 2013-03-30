class TestMailer < ActionMailer::Base
  default from: "contact@openaustraliafoundation.org.au"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test.test.subject
  #
  def test
    mail subject: "This is a test email from Cuttlefish",
      to: ["matthew@openaustralia.org", "mlandauer@yahoo.com"],
      cc: "kat@openaustralia.org",
      bcc: "matthew@planningalerts.org.au"
  end
end
