# frozen_string_literal: true

def database_exists?
  ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError
  false
else
  true
end

class InternalMailer < Devise::Mailer
  # Hacky way to not try to create cuttlefish app if apps table doesn't yet exist.
  # This can happen when you're doing a "rake db:setup"
  if database_exists? &&
     ActiveRecord::Base.connection.table_exists?(:apps) &&
     ActiveRecord::Base.connection.column_exists?(:apps, :cuttlefish)
      default delivery_method_options: {
        address: Rails.configuration.cuttlefish_domain,
        port: Rails.configuration.cuttlefish_smtp_port,
        user_name: App.cuttlefish.smtp_username,
        password: App.cuttlefish.smtp_password,
        # So that we don't get a certificate name and host mismatch we're just
        # disabling the check.
        openssl_verify_mode: "none",
        authentication: :plain
      }
  end

  def invitation_instructions(record, token, opts={})
    opts[:subject] = "#{record.invited_by.display_name} invites you to Cuttlefish"
    super
  end
end
