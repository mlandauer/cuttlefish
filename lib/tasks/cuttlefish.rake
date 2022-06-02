# frozen_string_literal: true

require File.expand_path(
  File.join(File.dirname(__FILE__), "..", "cuttlefish_control")
)

namespace :cuttlefish do
  desc "Start the Cuttlefish SMTP server"
  task :smtp do
    CuttlefishControl.new(Logger.new($stdout)).smtp_start
  end

  desc "Start the Postfix mail log sucker"
  task log: :environment do
    CuttlefishControl.new(Logger.new($stdout)).log_start
  end

  desc "Update status of email (if it is out of sync)"
  task update_status: :environment do
    Email.all.each(&:update_status!)
  end

  desc "Daily maintenance tasks to be run via cron job"
  task daily_tasks: %i[auto_archive remove_old_deny_listed_items]

  desc "Archive all emails created more than 3 months ago"
  task auto_archive: :environment do
    logger = Logger.new($stdout)
    date_to_archive_until = 3.months.ago.utc.to_date
    date_of_oldest_email = Delivery.order(:created_at).first.created_at.utc.to_date

    if date_of_oldest_email < date_to_archive_until
      (date_of_oldest_email...date_to_archive_until).each do |date|
        Archiving.new(logger).archive(date)
      end
    else
      logger.info "No emails created before #{date_to_archive_until} to archive"
    end
  end

  desc "Allow sending to addresses again that were deny listed more than 1 week ago"
  task remove_old_deny_listed_items: :environment do
    old_items = DenyList.where("updated_at < ?", 1.week.ago)
    puts "Removing #{old_items.count} items from the deny list..."
    old_items.destroy_all
  end

  desc "Archive all emails from a particular date (e.g. 2014-05-01)"
  task :archive, %i[date1 date2] => :environment do |_t, args|
    args.with_defaults(date2: args.date1)
    (Date.parse(args.date1)..Date.parse(args.date2)).each do |date|
      Archiving.new(Logger.new($stdout)).archive(date)
    end
  end

  desc "Copy archive to S3 (if it was missed as part of the archive task)"
  task :copy_archive_to_s3, %i[date1 date2] => :environment do |_t, args|
    raise "S3 not configured" unless ENV["S3_BUCKET"]

    args.with_defaults(date2: args.date1)
    (Date.parse(args.date1)..Date.parse(args.date2)).each do |date|
      Archiving.new(Logger.new($stdout)).copy_to_s3(date)
    end
  end

  # This is just a temporary task to export some semi-anonymised production
  # delivery event data that can be used to develop a filter to categorise
  # events into different types (e.g. incorrect email address, suspected spam,
  # etc..)
  task export_redacted_hard_bounce_delivery_events: :environment do
    require "csv"

    CSV.open("hard_bounce_delivery_events.csv", "w") do |csv|
      csv << ["dsn", "extended status"]
      PostfixLogLine.find_each do |log|
        if log.dsn_class == 5
          # We want to remove this address from the extended status
          address = log.delivery.address.text
          domain = address.split("@")[1]
          redacted = log.extended_status
                        .gsub(address, "foo@example.com")
                        .gsub(domain, "example.com")

          csv << [log.dsn, redacted]
        end
      end
    end
  end

  # Little "proof of concept" of generating an SSL certificate
  desc "Create SSL certificate (proof of concept)"
  task :create_ssl_certificate, [:domain] => :environment do |_t, args|
    require "openssl"

    domain = args[:domain]
    puts "Generating certificate for #{domain}..."

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
