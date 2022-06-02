# frozen_string_literal: true

class Certificate
  ROOT_DIRECTORY = "/etc/cuttlefish-ssl"
  ACME_SERVER_KEY_FILENAME = File.join(ROOT_DIRECTORY, "keys", "key.pem")
  LETSENCRYPT_PRODUCTION = "https://acme-v02.api.letsencrypt.org/directory"
  LETSENCRYPT_STAGING = "https://acme-staging-v02.api.letsencrypt.org/directory"

  def self.generate(domain)
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
    raise "Challenge failed: #{challenge.status}" unless challenge.status == "valid"

    # Clean up the challenge
    AcmeChallenge.find_by!(token: challenge.token).destroy

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
    create_directory_and_write(cert_private_key_filename(domain), certificate_private_key.export)
    create_directory_and_write(cert_filename(domain), order.certificate)

    # TODO: Skip the certificate generation if it's already valid and isn't about to expire
    # Now create the nginx configuration for that domain
    create_directory_and_write(nginx_filename(domain), nginx_config(domain))
    # TODO: Check that nginx config is all good and reload nginx
  end

  # We'll put everything under /etc/cuttlefish-ssl in a naming convention
  # that is similar to what let's encrypt uses
  def self.cert_private_key_filename(domain)
    File.join(ROOT_DIRECTORY, "live", domain, "privkey.pem")
  end

  # We'll put everything under /etc/cuttlefish-ssl in a naming convention
  # that is similar to what let's encrypt uses
  def self.cert_filename(domain)
    File.join(ROOT_DIRECTORY, "live", domain, "fullchain.pem")
  end

  def self.nginx_filename(domain)
    File.join(ROOT_DIRECTORY, "nginx-sites", domain)
  end

  def self.nginx_config(domain)
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
    contents << "  ssl_certificate /etc/cuttlefish-ssl/live/#{domain}/fullchain.pem;\n"
    contents << "  ssl_certificate_key /etc/cuttlefish-ssl/live/#{domain}/privkey.pem;\n"
    contents << "}\n"
    contents
  end

  def self.acme_server_key
    if File.exist?(ACME_SERVER_KEY_FILENAME)
      OpenSSL::PKey::RSA.new(File.read(ACME_SERVER_KEY_FILENAME))
    else
      private_key = OpenSSL::PKey::RSA.new(4096)
      create_directory_and_write(ACME_SERVER_KEY_FILENAME, private_key.export)
      private_key
    end
  end

  def self.create_directory_and_write(filename, content)
    FileUtils.mkdir_p(File.dirname(filename))
    File.write(filename, content)
  end
end
