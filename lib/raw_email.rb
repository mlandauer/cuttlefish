class RawEmail
  attr_reader :from, :to, :data

  def initialize(from, to, data)
    @from, @to, @data = from, to, data
  end

  def record
    Email.create!(:from => from, :to => to)
  end

  # Send this mail to another smtp server
  def forward(server, port)
    Net::SMTP.start(server, port) do |smtp|
      smtp.send_message(data, from, to)
    end    
  end
end
