class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines

  def delivered
    unless postfix_log_lines.empty?
      postfix_log_lines.any? {|l| l.delivered? }
    end
  end

  def delivered_status_known?
    !delivered.nil?
  end
end
