class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }

  after_save :update_status!
  
  # Should this email be sent to this address?
  # If not it's because the email has bounced
  def send?
    address.status != "hard_bounce"
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
