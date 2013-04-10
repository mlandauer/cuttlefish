class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address

  def delivered
    unless postfix_log_lines.empty?
      postfix_log_lines.any? {|l| l.delivered? }
    end
  end

  def delivered_status_known?
    !delivered.nil?
  end

  def postfix_log_lines
    email.postfix_log_lines.where(to: address.text)
  end
end
