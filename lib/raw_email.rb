class RawEmail
  attr_reader :from, :to, :data

  def initialize(from, to, data)
    @from, @to, @data = from, to, data
  end

  def record
    to_addresses = to.map{|t| EmailAddress.find_or_create_by(address: t)}
    Email.create!(:from => from, :to => to.join(', '))
  end

  # Send this mail to another smtp server
  def forward(server, port)
    Net::SMTP.start(server, port) do |smtp|
      smtp.send_message(data, from, to)
    end    
  end
end
