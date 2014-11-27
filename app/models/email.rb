class Email < ActiveRecord::Base
  belongs_to :from_address, class_name: "Address"
  has_many :deliveries, dependent: :destroy
  has_many :to_addresses, through: :deliveries, source: :address
  belongs_to :app
  has_many :open_events, through: :deliveries
  has_many :click_events, through: :deliveries

  after_create :update_cache
  before_save :update_message_id, :update_data_hash, :update_subject

  delegate :custom_tracking_domain, :open_tracking_enabled?, :click_tracking_enabled?, to: :app

  # TODO Add validations

  attr_writer :data

  def from
    # TODO: Remove the "if" once we've added validations
    from_address.text if from_address
  end

  def from_domain
    # TODO: Remove the "if" once we've added validations
    from_address.domain if from_address
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
    @data ||= EmailDataCache[id]
  end

  def mail
    Mail.new(data)
  end

  def text_part
    part("text/plain")
  end

  def html_part
    part("text/html")
  end

  # First part with a particular mime type
  # If a part is itself multipart then recurse down
  def part(mime_type, section = nil)
    section = mail if section.nil?
    if section.multipart?
      section.parts.each do |p|
        if part(mime_type, p)
          return part(mime_type, p)
        end
      end
      nil
    else
      if section.mime_type == mime_type
        section.decoded
      end
    end
  end

  def update_cache
    EmailDataCache[id] = data
  end

  def opened?
    !open_events.empty?
  end

  def clicked?
    !click_events.empty?
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

  def update_subject
    self.subject = Mail.new(data).subject
  end
end
