class Email < ActiveRecord::Base
  belongs_to :from_address, :class_name => "Address"
  has_and_belongs_to_many :to_addresses, :class_name => "Address", :join_table => "deliveries"
  has_many :deliveries

  after_save :save_data_to_filesystem, :cleanup_filesystem_data_store
  before_save :update_message_id, :update_data_hash

  # TODO Add validations

  attr_writer :data

  def self.sent_today
    where('created_at > ?', Date.today.beginning_of_day)
  end

  def self.sent_this_week
    where('created_at > ?', 7.days.ago)
  end

  def self.delivered_today
    sent_today.where(:delivered => true)
  end

  def self.not_delivered_today
    sent_today.where(:delivered => false)
  end

  def self.delivered_this_week
    sent_this_week.where(:delivered => true)
  end

  def self.not_delivered_this_week
    sent_this_week.where(:delivered => false)
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

  def overall_delivery_status
    if deliveries.all? {|delivery| delivery.delivered_status_known? }
      deliveries.all? {|delivery| delivery.delivered }
    end
  end

  def calculated_delivery_status
    if deliveries.any? {|delivery| delivery.status == "unknown" }
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

  def update_delivery_status!
    update_attribute(:delivered, overall_delivery_status)
  end

  def text_part
    if part("text/plain")
      part("text/plain")
    else
      Mail.new(data).body.to_s
    end
  end

  def html_part
    part("text/html")
  end

  # First part with a particular mime type
  def part(mime_type)
    part = Mail.new(data).parts.find{|p| p.mime_type == mime_type}
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

  # When a message is sent via the Postfix MTA it returns the queue id
  # in the SMTP message. Extract this
  def self.extract_postfix_queue_id_from_smtp_message(message)
    m = message.match(/250 2.0.0 Ok: queued as (\w+)/)
    m[1] if m
  end

  # Send this mail to another smtp server
  def forward(server, port)
    Net::SMTP.start(server, port) do |smtp|
      response = smtp.send_message(data, from, to)
      update_attribute(:postfix_queue_id, Email.extract_postfix_queue_id_from_smtp_message(response.message)) 
    end    
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
