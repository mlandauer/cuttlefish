class Email < ActiveRecord::Base
  belongs_to :from_address, :class_name => "Address"
  has_and_belongs_to_many :to_addresses, :class_name => "Address", :join_table => "deliveries"
  has_many :deliveries

  after_save :save_data_to_filesystem, :cleanup_filesystem_data_store
  before_save :update_message_id, :update_data_hash

  # TODO Add validations

  attr_writer :data

  def self.stats_today
    stats_for_emails(where('created_at > ?', Date.today.beginning_of_day))
  end

  def self.stats_this_week
    stats_for_emails(where('created_at > ?', 7.days.ago))
  end

  # Do a standard set of statistics over a set of emails
  def self.stats_for_emails(emails)
    counts = emails.group(:status).count
    {
      total: counts.values.sum,
      not_sent: counts["not_sent"] || 0,
      delivered: counts["delivered"] || 0,
      soft_bounce: counts["soft_bounce"] || 0,
      hard_bounce: counts["hard_bounce"] || 0
    }
  end

  def from
    # TODO: Remove the "if" once we've added validations
    from_address.text if from_address
  end

  def from=(a)
    self.from_address = Address.find_or_create_by(text: a)
  end

  def to
    to_addresses.map{|t| t.text}
  end

  def to=(a)
    a = [a] unless a.respond_to?(:map)
    self.to_addresses = a.map{|t| Address.find_or_create_by(text: t)}
  end

  def to_as_string
    to.join(", ")
  end

  def data
    @data ||= (File.read(data_filesystem_path) if is_data_on_filesystem?)
  end

  # TODO Extract status out into a value object
  def calculated_status
    if deliveries.any? {|delivery| delivery.status == "not_sent" }
      "not_sent"
    elsif deliveries.any? {|delivery| delivery.status == "unknown" }
      "unknown"
    elsif deliveries.any? {|delivery| delivery.status == "hard_bounce" }
      "hard_bounce"
    elsif deliveries.any? {|delivery| delivery.status == "soft_bounce" }
      "soft_bounce"
    elsif deliveries.all? {|delivery| delivery.status == "delivered" }
      "delivered"
    else
      raise "Unexpected situation"
    end
  end

  def update_status!
    update_attribute(:status, calculated_status)
  end

  def mail
    Mail.new(data)
  end

  def text_part
    part("text/plain") || mail.body.to_s
  end

  def html_part
    part("text/html")
  end

  # First part with a particular mime type
  def part(mime_type)
    part = mail.parts.find{|p| p.mime_type == mime_type}
    part.body.to_s if part
  end

  def self.max_no_emails_to_store_data
    # By default keep the full content of the last 100 emails
    100
  end

  def cleanup_filesystem_data_store
    # If there are more than a certain number of stored emails on the filesystem
    # remove the oldest ones
    entries = Dir.glob(File.join(Email.data_filesystem_directory, "*"))
    no_to_remove = entries.count - Email.max_no_emails_to_store_data
    if no_to_remove > 0
      # Oldest first
      entries.sort_by {|f| File.mtime f}[0...no_to_remove].each {|f| File.delete f}
    end
  end

  def save_data_to_filesystem
    # Don't overwrite the data that's already on the filesystem
    unless is_data_on_filesystem?
      # Save the data part of the email to the filesystem
      FileUtils::mkdir_p(Email.data_filesystem_directory)
      File.open(data_filesystem_path, "w") do |f|
        f.write(data)
      end
    end
  end

  def is_data_on_filesystem?
    File.exists?(data_filesystem_path)
  end

  def self.data_filesystem_directory
    File.join("db", "emails", Rails.env)
  end

  def data_filesystem_path
    File.join(Email.data_filesystem_directory, "#{id}.txt")
  end

  private

  def update_message_id
    # Just need to extract the Message-ID header. Could do this by parsing the whole email using
    # the Mail gem but this seems wasteful.
    match = data.match(/Message-ID: <([^>]+)>/) if data
    # Would expect there always to be a message id but we will be more lenient for the time being
    self.message_id = match[1] if match
  end

  def update_data_hash
    self.data_hash = Digest::SHA1.hexdigest(data) if data
  end
end
