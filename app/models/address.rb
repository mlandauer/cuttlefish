class Address < ActiveRecord::Base
  has_many :emails_sent, :class_name => "Email", :foreign_key => "from_address_id"
  has_and_belongs_to_many :emails_received, :class_name => "Email", :join_table => "deliveries"

  # Time this email address was last sent an email (doesn't necessarily mean that it arrived)
  def time_last_received
    a = emails_received.order("created_at DESC").first
    a.created_at if a
  end

  def time_last_sent
    a = emails_sent.order("created_at DESC").first
    a.created_at if a
  end

end
