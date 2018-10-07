# frozen_string_literal: true

class App < ActiveRecord::Base
  has_many :emails
  has_many :deliveries
  belongs_to :team

  validates :name, presence: true,
                   format: {
                     with: /\A[a-zA-Z0-9_ ]+\z/,
                     message: "only letters, numbers, spaces and underscores"
                   }
  validate :custom_tracking_domain_points_to_correct_place
  validate :validate_dkim_settings
  # Validating booleans so that they can't have nil values.
  # See https://stackoverflow.com/questions/34759092/to-validate-or-not-to-validate-boolean-field
  validates :smtp_password_locked, inclusion: { in: [true, false] }
  validates :open_tracking_enabled, inclusion: { in: [true, false] }
  validates :click_tracking_enabled, inclusion: { in: [true, false] }
  validates :dkim_enabled, inclusion: { in: [true, false] }
  validates :cuttlefish, inclusion: { in: [true, false] }
  validates :legacy_dkim_selector, inclusion: { in: [true, false] }

  before_create :set_smtp_password
  after_create :set_smtp_username

  def self.cuttlefish
    App.find_by(cuttlefish: true) ||
      App.create(cuttlefish: true, name: "Cuttlefish")
  end

  def new_password!
    return if smtp_password_locked?

    set_smtp_password
    save!
  end

  def from_domain
    if cuttlefish?
      Rails.configuration.cuttlefish_domain
    else
      read_attribute(:from_domain)
    end
  end

  def dkim_selector_legacy_value
    "cuttlefish"
  end

  def dkim_selector_current_value
    "#{smtp_username}.cuttlefish"
  end

  def dkim_selector
    if legacy_dkim_selector
      dkim_selector_legacy_value
    else
      dkim_selector_current_value
    end
  end

  def dkim_private_key
    if read_attribute(:dkim_private_key).nil?
      update_attributes(dkim_private_key: OpenSSL::PKey::RSA.new(2048).to_pem)
    end
    OpenSSL::PKey::RSA.new(read_attribute(:dkim_private_key))
  end

  def tracking_domain_info
    if Rails.env.development?
      { protocol: "http", domain: "localhost:3000" }
    elsif custom_tracking_domain?
      # We can't use https with a custom tracking domain because otherwise
      # we would need an SSL certificate installed for every custom domain used
      # and that's going to be way too much hassle for users
      { protocol: "http", domain: custom_tracking_domain }
    else
      { protocol: "https", domain: Rails.configuration.cuttlefish_domain }
    end
  end

  # Are we using a custom tracking domain?
  def custom_tracking_domain?
    custom_tracking_domain.present?
  end

  def self.lookup_dns_cname_record(domain)
    # Use our default nameserver
    n = Resolv::DNS.new.getresource(
      domain, Resolv::DNS::Resource::IN::CNAME
    ).name
    # Doing this to maintain compatibility with previous implementation
    # of this method
    if n.absolute?
      n.to_s + "."
    else
      n.to_s
    end
  rescue Resolv::ResolvError
    nil
  end

  private

  def validate_dkim_settings
    return unless dkim_enabled?

    if from_domain.present?
      # Check that DNS is setup
      dkim = DkimDns.new(
        domain: from_domain,
        private_key: dkim_private_key,
        selector: dkim_selector
      )
      return if dkim.dkim_dns_configured?

      errors.add(
        :from_domain,
        "Doesn't have a DNS record configured correctly for #{dkim.dkim_domain}"
      )
    else
      errors.add(
        :dkim_enabled,
        "Can't be enabled if from_domain is not set"
      )
    end
  end

  def cname_domain
    # In DNS speak putting a "." after the domain makes it a full domain
    # name rather than just relative to the current higher level domain
    Rails.configuration.cuttlefish_domain + "."
  end

  def valid_dns_for_custom_tracking_domain
    App.lookup_dns_cname_record(custom_tracking_domain) == cname_domain
  end

  def custom_tracking_domain_points_to_correct_place
    return if custom_tracking_domain.blank?
    return if valid_dns_for_custom_tracking_domain

    errors.add(
      :custom_tracking_domain,
      "Doesn't have a CNAME record that points to #{cname_domain}"
    )
  end

  def set_smtp_password
    self.smtp_password =
      Digest::MD5.base64digest(rand.to_s + Time.now.to_s)[0...20]
  end

  def set_smtp_username
    # By appending the id we can be confident that this name is globally unique
    update_attributes(smtp_username: name.downcase.tr(" ", "_") + "_" + id.to_s)
  end
end
