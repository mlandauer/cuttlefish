class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }
  has_many :open_events

  after_save :update_status!
  
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
end
