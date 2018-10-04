# frozen_string_literal: true

class Email < ActiveRecord::Base
  belongs_to :from_address, class_name: "Address"
  has_many :deliveries, dependent: :destroy
  has_many :to_addresses, through: :deliveries, source: :address
  belongs_to :app
  has_many :open_events, through: :deliveries
  has_many :click_events, through: :deliveries

  after_create :update_cache
  before_save :update_message_id, :update_data_hash, :update_subject,
              :update_from

  delegate :custom_tracking_domain, :tracking_domain, :custom_tracking_domain?,
           :open_tracking_enabled?, :click_tracking_enabled?,
           to: :app

  # TODO: Add validations

  attr_writer :data

  def from
    # TODO: Remove the "if" once we've added validations
    from_address&.text
  end

  def from_domain
    # TODO: Remove the "if" once we've added validations
    from_address&.domain
  end

  def from=(text)
    self.from_address = Address.find_or_create_by(text: text)
  end

  def to
    to_addresses.map(&:text)
  end

  def to=(addresses)
    addresses = [addresses] unless addresses.respond_to?(:map)
    self.to_addresses = addresses.map { |t| Address.find_or_create_by(text: t) }
  end

  def to_as_string
    to.join(", ")
  end

  def email_cache
    EmailDataCache.new(
      File.join(Rails.env, app_id.to_s),
      Rails.configuration.max_no_emails_to_store
    )
  end

  def data
    @data ||= email_cache.get(id)
  end

  # TODO: Make sure that data doesn't get modified after creation otherwise
  # this cache is invalid
  def mail
    @mail ||= Mail.new(data)
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
        return part(mime_type, p) if part(mime_type, p)
      end
      nil
    elsif (section.mime_type == mime_type) ||
          (section.mime_type.nil? && mime_type == "text/plain")
      section.decoded
    end
  end

  def opened?
    !open_events.empty?
  end

  def clicked?
    !click_events.empty?
  end

  private

  def update_cache
    email_cache.set(id, data)
  end

  def update_data_hash
    self.data_hash = Digest::SHA1.hexdigest(data) if data
  end

  def update_message_id
    self.message_id = mail.message_id
  end

  def update_subject
    self.subject = mail.subject
  end

  def update_from
    # There can be multiple from addresses in the body of the mail
    # but we'll only take the first. See
    # https://github.com/mlandauer/cuttlefish/issues/315
    self.from = mail.from.first if mail.from
  end
end
