class OutgoingEmail
  attr_reader :email

  def initialize(email)
    @email = email
  end

  def send
    unless deliveries.empty?
      Net::SMTP.start(Rails.configuration.postfix_smtp_host, Rails.configuration.postfix_smtp_port) do |smtp|
        response = smtp.send_message(data, from, to)
        email.update_attribute(:postfix_queue_id, OutgoingEmail.extract_postfix_queue_id_from_smtp_message(response.message)) 
      end
      deliveries.each {|delivery| delivery.update_attribute(:sent, true) }
    end
  end

  # When a message is sent via the Postfix MTA it returns the queue id
  # in the SMTP message. Extract this
  def self.extract_postfix_queue_id_from_smtp_message(message)
    m = message.match(/250 2.0.0 Ok: queued as (\w+)/)
    m[1] if m
  end

  private

  # TODO: It has the potential to be different for each delivery
  def from
    email.from
  end

  # This is the raw email data that we will send out
  # It can be different than the original
  # TODO: It has the potential to be different for each delivery
  def data
    email.data
  end

  # The list of email addresses we will actually forward this to
  # This list could be smaller than "to" if some of the email addresses have hard bounced
  def deliveries
    email.deliveries.select{|delivery| delivery.forward?}
  end

  def to
    deliveries.map{|d| d.address.text}
  end
end
