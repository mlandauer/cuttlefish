class Email < ActiveRecord::Base
  belongs_to :from_address, :class_name => "EmailAddress"
  # Note that currently the data (the main bit of the email) isn't persisted
  attr_accessor :data

  def from
    from_address.address
  end

  def from=(a)
    self.from_address = EmailAddress.find_or_create_by(address: a)
  end

  def to
    read_attribute(:to).split(", ")
  end

  def to=(a)
    a.map{|t| EmailAddress.find_or_create_by(address: t)}
    write_attribute(:to, a.join(", "))
  end

  # Doing this in the dumbest way to start with
  def to_addresses
    to.map{|t| EmailAddress.find_by_address(t)}
  end

  # Send this mail to another smtp server
  def forward(server, port)
    Net::SMTP.start(server, port) do |smtp|
      smtp.send_message(data, from, to)
    end    
  end
end
