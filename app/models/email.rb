class Email < ActiveRecord::Base
  belongs_to :from_address, :class_name => "EmailAddress"
  has_and_belongs_to_many :to_addresses, :class_name => "EmailAddress", :join_table => "to_addresses_emails"

  # Note that currently the data (the main bit of the email) isn't persisted
  attr_accessor :data

  def from
    from_address.address
  end

  def from=(a)
    self.from_address = EmailAddress.find_or_create_by(address: a)
  end

  def to
    to_addresses.map{|t| t.address}
  end

  def to=(a)
    a = [a] unless a.respond_to?(:map)
    self.to_addresses = a.map{|t| EmailAddress.find_or_create_by(address: t)}
  end

  # Send this mail to another smtp server
  def forward(server, port)
    Net::SMTP.start(server, port) do |smtp|
      smtp.send_message(data, from, to)
    end    
  end
end
