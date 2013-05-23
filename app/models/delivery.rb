class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }
  has_many :open_events

  after_save :update_status!
  
  def self.today
    where('created_at > ?', Date.today.beginning_of_day)
  end

  def self.this_week
    where('created_at > ?', 7.days.ago)
  end

  # This delivery is being open tracked
  def set_open_tracked!
    update_attributes(open_tracked: true, open_tracked_hash: open_tracked_hash2)
  end

  def add_open_event(request)
    open_events.create!(
      user_agent: request.env['HTTP_USER_AGENT'],
      referer: request.referer,
      ip: request.remote_ip
    )
  end

  def open_tracked_hash2
    # TODO: Move the salt to configuration
    salt = "my salt"
    Digest::SHA1.hexdigest(salt + id.to_s)    
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
end
