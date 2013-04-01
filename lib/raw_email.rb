class RawEmail
  attr_reader :from, :to, :data

  def initialize(from, to, data)
    @from, @to, @data = from, to, data
  end

  def record
    from_address = EmailAddress.find_or_create_by(address: from)
    to_addresses = to.map{|t| EmailAddress.find_or_create_by(address: t)}
    Email.create!(:from_address => from_address, :to => to.join(', '))
  end

  # Send this mail to another smtp server
  def forward(server, port)
    Net::SMTP.start(server, port) do |smtp|
      smtp.send_message(data, from, to)
    end    
  end
end
