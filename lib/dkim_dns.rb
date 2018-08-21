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

  # The string that needs to be inserted in DNS.
  # This string format works at least for the service DNS Made Easy.
  def dkim_dns_value_quoted
    DkimDns.quote_long_dns_txt_record(dkim_dns_value)
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
    begin
      Resolv::DNS.new.getresource(dkim_domain, Resolv::DNS::Resource::IN::TXT).strings.join
    rescue Resolv::ResolvError
      nil
    end
  end

  def dkim_dns_configured?
    resolve_dkim_dns_value == dkim_dns_value
  end

  def sign_mail(mail)
    Mail.new(Dkim.sign(mail.to_s, selector: selector, private_key: private_key, domain: domain))
  end

  private

  def public_key_der_encoded
    Base64.strict_encode64(public_key.to_der)
  end

  # If a DNS TXT record is longer than 255 characters it needs to be split into several
  # separate strings
  def self.quote_long_dns_txt_record(text)
    text.scan(/.{1,255}/).map{|s| '"' + s + '"'}.join
  end

end
