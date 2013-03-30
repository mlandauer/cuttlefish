class Email < ActiveRecord::Base
  belongs_to :from_address, :class_name => "EmailAddress"

  def from
    from_address.address
  end
end
