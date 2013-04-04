class TestMailer < ActionMailer::Base
  default from: "contact@openaustraliafoundation.org.au"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test.test.subject
  #
  def test
    mail subject: "This is a test email from Cuttlefish",
      to: ["Matthew Landauer <matthew@openaustralia.org>", "mlandauer@yahoo.com"],
      cc: "matthew@planningalerts.org.au"
  end
end
