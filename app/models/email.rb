class Email < ActiveRecord::Base
  belongs_to :from_address, :class_name => "EmailAddress"
  has_and_belongs_to_many :to_addresses, :class_name => "EmailAddress", :join_table => "to_addresses_emails"
  has_many :postfix_log_lines, -> { order :time }

  after_save :save_data_to_filesystem, :cleanup_filesystem_data_store

  # TODO Add validations

  attr_writer :data

  def self.no_emails_sent_today
    where('created_at > ?', Date.today.beginning_of_day).count
  end

  def from
    # TODO: Remove the "if" once we've added validations
    from_address.address if from_address
  end

  def from=(a)
    self.from_address = EmailAddress.find_or_create_by(address: a)
  end

  def to
    to_addresses.map{|t| t.address}
  end

  def to=(a)
    a = [a] unless a.respond_to?(:map)
    self.to_addresses = a.map{|t| EmailAddress.find_or_create_by(address: t)}
  end

  def to_as_string
    to.join(", ")
  end

  def data
    @data ||= File.read(data_filesystem_path) if is_data_on_filesystem?
  end

  # Check the delivery status for a particular email
  def delivery_status(email)
    unless postfix_log_lines_for_email(email).empty?
      postfix_log_lines_for_email(email).any? {|l| l.delivered? }
    end
  end

  def postfix_log_lines_for_email(email)
    postfix_log_lines.select{|l| l.to == email}
  end

  def overall_delivery_status
    if to.all? {|email| !delivery_status(email).nil? }
      to.all? {|email| delivery_status(email) }
    end
  end

  def update_delivery_status!
    update_attribute(:delivered, overall_delivery_status)
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
    # Save the data part of the email to the filesystem
    FileUtils::mkdir_p(Email.data_filesystem_directory)
    File.open(data_filesystem_path, "w") do |f|
      f.write(data)
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
end
