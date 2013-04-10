class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }

  def delivered
    unless postfix_log_lines.empty?
      # Take the delivery status from the last delivery attempt
      postfix_log_lines.first.delivered?
    end
  end

  def delivered_status_known?
    !delivered.nil?
  end

  def status
    last_line = postfix_log_lines.first
    last_line ? last_line.delivery_status : "unknown"
  end
end
