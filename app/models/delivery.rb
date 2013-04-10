class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }

  def delivered
    if status != "unknown"
      status == "delivered"
    end
  end

  def delivered_status_known?
    status != "unknown"
  end

  def status
    last_line = postfix_log_lines.first
    last_line ? last_line.delivery_status : "unknown"
  end
end
