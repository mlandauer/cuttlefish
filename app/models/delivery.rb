class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }
  has_many :open_events

  after_save :update_status!
  
  def self.today
    # Currently created_at on deliveries doesn't get set so have to get the time from emails
    # TODO Get rid of join
    joins(:email).where('emails.created_at > ?', Date.today.beginning_of_day)
  end

  def self.this_week
    # Currently created_at on deliveries doesn't get set so have to get the time from emails
    # TODO Get rid of join
    joins(:email).where('emails.created_at > ?', 7.days.ago)
  end

  # This delivery is being open tracked
  def set_open_tracked!
    # TODO: Move the salt to configuration
    salt = "my salt"
    hash = Digest::SHA1.hexdigest(salt + id.to_s)
    update_attributes(open_tracked: true, open_tracked_hash: hash)
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
    open_events.count > 0
  end
end
