# frozen_string_literal: true

class DkimDns
  attr_accessor :private_key, :domain, :selector

  def initialize(domain:, private_key:, selector:)
    @private_key = private_key
    @domain = domain
    @selector = selector
  end

  def dkim_domain
    "#{selector}._domainkey.#{domain}"
  end

  def dkim_dns_value
    "k=rsa; p=#{public_key_der_encoded}"
  end

  def public_key
    # We can generate the public key from the private key
    private_key.public_key
  end

  def resolve_dkim_dns_value
    # Use our default nameserver
    Resolv::DNS.new.getresource(
      dkim_domain,
      Resolv::DNS::Resource::IN::TXT
    ).strings.join
  rescue Resolv::ResolvError
    nil
  end

  def dkim_dns_configured?
    resolve_dkim_dns_value == dkim_dns_value
  end

  def sign_mail(mail)
    # Directly inserting the header for the dkim signature into the mail
    # This is to avoid a problem where the interaction between the signing
    # of the complete email using the dkim library followed by a reparsing
    # of the whole email was causing the body to change slightly causing
    # the dkim signature to not work.
    dkim_header = Dkim::SignedMail.new(
      mail.to_s,
      selector: selector,
      private_key: private_key,
      domain: domain
    ).dkim_header

    signed_mail = mail.clone
    signed_mail.header[dkim_header.key] = dkim_header.value
    signed_mail
  end

  private

  def public_key_der_encoded
    Base64.strict_encode64(public_key.to_der)
  end
end
