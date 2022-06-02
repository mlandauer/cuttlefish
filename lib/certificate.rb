# frozen_string_literal: true

class Certificate
  def self.generate(domain)
    directory = "/etc/cuttlefish-ssl/keys"
    filename = File.join(directory, "key.pem")
    private_key = OpenSSL::PKey::RSA.new(
      File.exist?(filename) ? File.read(filename) : 4096
    )

    client = Acme::Client.new(
      private_key: private_key,
      directory: "https://acme-v02.api.letsencrypt.org/directory"
    )

    unless File.exist?(filename)
      # Create an account
      client.new_account(
        # TODO: Make the email address configurable
        contact: "mailto:contact@oaf.org.au",
        terms_of_service_agreed: true
      )
      # Save the private key. Intentionally only doing this once the Let's Encrypt account has been created
      FileUtils.mkdir_p(directory)
      File.write(filename, private_key.export)
    end

    order = client.new_order(identifiers: [domain])
    authorization = order.authorizations.first
    challenge = authorization.http

    # Store the challenge in the database so that the web application
    # can respond correctly. We also need to handle the situation where we already have the
    # token in the database
    AcmeChallenge.find_or_create_by!(token: challenge.token).update!(content: challenge.file_content)

    # TODO: Clear out old challenges after a little while
    # Now actually ask let's encrypt to the validation
    challenge.request_validation

    # Now let's wait for the validation to finish
    while challenge.status == "pending"
      sleep(2)
      challenge.reload
    end

    # TODO: Double check that the challenge did actually succeed here

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

    # We'll put everything under /etc/cuttlefish-ssl in a naming convention
    # that is similar to what let's encrypt uses
    directory = "/etc/cuttlefish-ssl/live/#{domain}"
    certificate_private_key_filename = File.join(directory, "privkey.pem")
    certificate_filename = File.join(directory, "fullchain.pem")

    # The private key is owned by "deploy" rather than root which is less than
    # ideal. The only way to get around this would be for the csr request to
    # let's encrypt being done by a separate process

    FileUtils.mkdir_p(directory)
    File.write(certificate_private_key_filename, certificate_private_key.export)
    File.write(certificate_filename, order.certificate)

    # TODO: Skip the certificate generation if it's already valid and isn't about to expire
    # Now create the nginx configuration for that domain
    directory = "/etc/cuttlefish-ssl/nginx-sites"
    FileUtils.mkdir_p(directory)
    nginx_filename = File.join(directory, domain)

    File.open(nginx_filename, "w") do |f|
      f << "server {\n"
      f << "  listen 443 ssl http2;\n"
      f << "  server_name #{domain};\n"
      f << "\n"
      f << "  root /srv/www/current/public;\n"
      f << "  passenger_enabled on;\n"
      f << "  passenger_ruby /usr/local/lib/rvm/wrappers/default/ruby;\n"
      f << "\n"
      f << "  ssl on;\n"
      f << "  ssl_certificate /etc/cuttlefish-ssl/live/#{domain}/fullchain.pem;\n"
      f << "  ssl_certificate_key /etc/cuttlefish-ssl/live/#{domain}/privkey.pem;\n"
      f << "}\n"
    end

    # TODO: Check that nginx config is all good and reload nginx
  end
end
