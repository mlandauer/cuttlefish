# frozen_string_literal: true

class App < ActiveRecord::Base
  has_many :emails
  has_many :deliveries
  belongs_to :team

  validates :name, presence: true, format: {with: /\A[a-zA-Z0-9_ ]+\z/, message: "only letters, numbers, spaces and underscores"}
  validate :custom_tracking_domain_points_to_correct_place
  # Validating booleans so that they can't have nil values.
  # See https://stackoverflow.com/questions/34759092/to-validate-or-not-to-validate-boolean-field
  validates :smtp_password_locked, :inclusion => {:in => [true, false]}
  validates :open_tracking_enabled, :inclusion => {:in => [true, false]}
  validates :click_tracking_enabled, :inclusion => {:in => [true, false]}
  validates :dkim_enabled, :inclusion => {:in => [true, false]}
  validates :cuttlefish, :inclusion => {:in => [true, false]}
  validates :legacy_dkim_selector, :inclusion => {:in => [true, false]}

  before_create :set_smtp_password
  after_create :set_smtp_username

  def self.cuttlefish
    App.find_by(cuttlefish: true) || App.create(cuttlefish: true, name: "Cuttlefish")
  end

  def new_password!
    unless smtp_password_locked?
      set_smtp_password
      save!
    end
  end

  def from_domain
    if cuttlefish?
      Rails.configuration.cuttlefish_domain
    else
      read_attribute(:from_domain)
    end
  end

  def dkim_selector_legacy_value
    'cuttlefish'
  end

  def dkim_selector_current_value
    "#{smtp_username}.cuttlefish"
  end

  def dkim_selector
    legacy_dkim_selector ? dkim_selector_legacy_value : dkim_selector_current_value
  end

  def dkim_private_key
    if read_attribute(:dkim_private_key).nil?
      update_attributes(dkim_private_key: OpenSSL::PKey::RSA.new(2048).to_pem)
    end
    OpenSSL::PKey::RSA.new(read_attribute(:dkim_private_key))
  end

  def tracking_domain
    if custom_tracking_domain?
      custom_tracking_domain
    else
      Rails.configuration.cuttlefish_domain
    end
  end

  # Are we using a custom tracking domain?
  def custom_tracking_domain?
    custom_tracking_domain.present?
  end

  private

  def self.lookup_dns_cname_record(domain)
    # Use our default nameserver
    begin
      n = Resolv::DNS.new.getresource(domain, Resolv::DNS::Resource::IN::CNAME).name
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
  end

  def custom_tracking_domain_points_to_correct_place
    # In DNS speak putting a "." after the domain makes it a full domain name rather than just relative
    # to the current higher level domain
    cname_domain = Rails.configuration.cuttlefish_domain + "."
    unless custom_tracking_domain.blank?
      if App.lookup_dns_cname_record(custom_tracking_domain) != cname_domain
        errors.add(:custom_tracking_domain, "Doesn't have a CNAME record that points to #{cname_domain}")
      end
    end
  end

  def set_smtp_password
    self.smtp_password = Digest::MD5.base64digest(rand.to_s + Time.now.to_s)[0...20]
  end

  def set_smtp_username
    # By appending the id we can be confident that this name is globally unique
    update_attributes(smtp_username: name.downcase.gsub(" ", "_") + "_" + id.to_s)
  end
end
