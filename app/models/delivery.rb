class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address

  def delivered
    unless postfix_log_lines.empty?
      postfix_log_lines.any? {|l| l.delivered? }
    end
  end

  def postfix_log_lines
    email.postfix_log_lines.select{|l| l.to == address.address}
  end
end
