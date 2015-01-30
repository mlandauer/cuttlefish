class SignupForm < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :organisation_name
  attribute :organisation_url
  attribute :message

  def headers
    {
      subject: "Access request for cuttlefish.oaf.org.au",
      to: "contact@oaf.org.au",
      from: %("#{name}" <#{email}>)
    }
  end
end
