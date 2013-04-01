class RawEmail
  def initialize(from, to, data)
    @e = Email.new(from: from, to: to, data: data)
  end

  def from
    e.from
  end

  def to
    e.to
  end

  def data
    e.data
  end

  def record
    @e.save!
  end

  def forward(server, port)
    @e.forward(server, port)
  end
end
