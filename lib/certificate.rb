# frozen_string_literal: true

class Certificate
  ROOT_DIRECTORY = "/etc/cuttlefish-ssl"
  ACME_SERVER_KEY_FILENAME = File.join(ROOT_DIRECTORY, "keys", "key.pem")
  LETSENCRYPT_PRODUCTION = "https://acme-v02.api.letsencrypt.org/directory"
  LETSENCRYPT_STAGING = "https://acme-staging-v02.api.letsencrypt.org/directory"
  # If a certificate is going to expire in less than 28 days we'll try to renew it
  DAYS_TO_EXPIRY_CUTOFF = 28

  attr_reader :domain

  def initialize(domain)
    @domain = domain
  end

  def generate
    return unless new_cert_required?

    client = Acme::Client.new(
      private_key: acme_server_key,
      directory: LETSENCRYPT_STAGING
    )

    # Create an account. If we already have an account connected to that private key
    # it won't actually create a new one. So we can safely always call it.
    client.new_account(
      # TODO: Make the email address configurable
      contact: "mailto:contact@oaf.org.au",
      terms_of_service_agreed: true
    )

    order = client.new_order(identifiers: [domain])
    authorization = order.authorizations.first
    challenge = authorization.http

    # Store the challenge in the database so that the web application
    # can respond correctly. We also need to handle the situation where we already have the
    # token in the database
    AcmeChallenge.find_or_create_by!(token: challenge.token).update!(content: challenge.file_content)

    # Now actually ask let's encrypt to the validation
    challenge.request_validation

    # Now let's wait for the validation to finish
    while challenge.status == "pending"
      sleep(2)
      challenge.reload
    end
    # Clean up the challenge
    AcmeChallenge.find_by!(token: challenge.token).destroy

    raise "Challenge failed: #{challenge.status}" unless challenge.status == "valid"

    # Now we generate the private key for the certificate and store it away
    # in a place where nginx will ultimately access it
    certificate_private_key = OpenSSL::PKey::RSA.new(4096)

    # Now request the certificate
    csr = Acme::Client::CertificateRequest.new(
      private_key: certificate_private_key,
      subject: { common_name: domain }
    )
    order.finalize(csr: csr)
    while order.status == "processing"
      sleep(1)
      order.reload
    end

    # The private key is owned by "deploy" rather than root which is less than
    # ideal. The only way to get around this would be for the csr request to
    # let's encrypt being done by a separate process
    create_directory_and_write(cert_private_key_filename, certificate_private_key.export)
    create_directory_and_write(cert_filename, order.certificate)

    # Now create the nginx configuration for that domain
    create_directory_and_write(nginx_filename, nginx_config)

    raise "Couldn't reload nginx for some reason" unless reload_nginx
  end

  # Returns true if successful
  def reload_nginx
    # In our case the deploy user is allowed to do this particular command without
    # having to enter a password
    result = system("sudo service nginx configtest")
    return result unless result

    system("sudo service nginx reload")
  end

  def new_cert_required?
    # First let's just check if there's already a certificate. If so only generate a new
    # one if it's close to expiry
    return true unless File.exist?(cert_filename)

    cert = OpenSSL::X509::Certificate.new(File.read(cert_filename))
    days_to_expiry = (cert.not_after - Time.zone.now) / (60 * 60 * 24)
    days_to_expiry < DAYS_TO_EXPIRY_CUTOFF
  end

  # We'll put everything under /etc/cuttlefish-ssl in a naming convention
  # that is similar to what let's encrypt uses
  def cert_private_key_filename
    File.join(ROOT_DIRECTORY, "live", domain, "privkey.pem")
  end

  # We'll put everything under /etc/cuttlefish-ssl in a naming convention
  # that is similar to what let's encrypt uses
  def cert_filename
    File.join(ROOT_DIRECTORY, "live", domain, "fullchain.pem")
  end

  def nginx_filename
    File.join(ROOT_DIRECTORY, "nginx-sites", domain)
  end

  # TODO: Improve SSL setup - check with ssllabs.com
  def nginx_config
    contents = +""
    contents << "server {\n"
    contents << "  listen 443 ssl http2;\n"
    contents << "  server_name #{domain};\n"
    contents << "\n"
    contents << "  root /srv/www/current/public;\n"
    contents << "  passenger_enabled on;\n"
    contents << "  passenger_ruby /usr/local/lib/rvm/wrappers/default/ruby;\n"
    contents << "\n"
    contents << "  ssl on;\n"
    contents << "  ssl_certificate #{cert_filename};\n"
    contents << "  ssl_certificate_key #{cert_private_key_filename};\n"
    contents << "}\n"
    contents
  end

  def acme_server_key
    if File.exist?(ACME_SERVER_KEY_FILENAME)
      OpenSSL::PKey::RSA.new(File.read(ACME_SERVER_KEY_FILENAME))
    else
      private_key = OpenSSL::PKey::RSA.new(4096)
      create_directory_and_write(ACME_SERVER_KEY_FILENAME, private_key.export)
      private_key
    end
  end

  def create_directory_and_write(filename, content)
    FileUtils.mkdir_p(File.dirname(filename))
    File.write(filename, content)
  end
end
