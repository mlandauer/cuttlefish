class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }

  def status
    last_line = postfix_log_lines.first
    last_line ? last_line.status : "unknown"
  end
end
