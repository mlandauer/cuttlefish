class App < ActiveRecord::Base
  has_many :emails, dependent: :destroy

  validates :name, presence: true, format: {with: /\A[a-zA-Z0-9_ ]+\z/, message: "Only letters, numbers, spaces and underscores"}
  validate :custom_tracking_domain_points_to_correct_place

  before_create :set_smtp_password
  after_create :set_smtp_username

  def new_password!
    unless smtp_password_locked?
      set_smtp_password
      save!
    end
  end

  # Singleton for returning special App used for sending mail from Cuttlefish itself
  def self.default
    App.find_by(default_app: true) || App.create!(name: "Default", default_app: true)
  end

  # Have there been any apps created?
  def self.normal_apps?
    where(default_app: false).exists?
  end

  def dkim_public_key
    # We can generate the public key from the private key
    OpenSSL::PKey::RSA.new(dkim_private_key).public_key.to_pem
  end

  # The string that needs to be inserted in DNS
  def dkim_public_key_dns
    App.quote_long_dns_txt_record("k=rsa; p=" + dkim_public_key.split("\n")[1..-2].join)
  end

  def dkim_private_key
    update_attributes(dkim_private_key: OpenSSL::PKey::RSA.new(2048).to_pem) if read_attribute(:dkim_private_key).nil?
    read_attribute(:dkim_private_key)
  end

  private

  # If a DNS TXT record is longer than 255 characters it needs to be split into several
  # separate strings
  def self.quote_long_dns_txt_record(text)
    text.scan(/.{1,255}/).map{|s| '"' + s + '"'}.join
  end

  def self.lookup_dns_cname_record(domain)
    cname_record = Net::DNS::Resolver.start(domain, Net::DNS::CNAME).answer.first
    cname_record.value if cname_record
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
