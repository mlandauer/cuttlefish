class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address

  def delivered
    lines = email.postfix_log_lines.select{|l| l.to == address.address}
    unless lines.empty?
      lines.any? {|l| l.delivered? }
    end
  end
end
