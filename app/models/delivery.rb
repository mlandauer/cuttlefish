class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }

  # Should this email be sent to this address?
  # If not it's because the email has bounced
  def forward?
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
end
