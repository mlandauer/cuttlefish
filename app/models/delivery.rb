class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }
  has_many :open_events
  has_many :delivery_links
  has_many :link_events, through: :delivery_links

  after_save :update_status!
  
  def self.today
    where('created_at > ?', Date.today.beginning_of_day)
  end

  def self.this_week
    where('created_at > ?', 7.days.ago)
  end

  # This delivery is being open tracked
  def set_open_tracked!
    update_attributes(open_tracked: true)
  end

  def add_open_event(request)
    open_events.create!(
      user_agent: request.env['HTTP_USER_AGENT'],
      referer: request.referer,
      ip: request.remote_ip
    )
  end

  def open_tracked_hash
    HashId.hash(id)
  end

  def valid_open_tracked_hash?(h)
    HashId.valid?(id, h)
  end

  def open_tracking_enabled?
    email.open_tracking_enabled?
  end

  def link_tracking_enabled?
    email.link_tracking_enabled?
  end

  def status
    if sent?
      last_line = postfix_log_lines.first
      last_line ? last_line.status : "unknown"
    else
      "not_sent"
    end
  end

  def update_status!
    email.update_status!
  end

  def from
    email.from
  end

  def to
    address.text
  end

  def data
    email.data
  end

  def opened?
    !open_events.empty?
  end

  def clicked?
    !link_events.empty?
  end
end
