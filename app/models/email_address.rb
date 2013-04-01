class EmailAddress < ActiveRecord::Base
  has_many :emails_sent, :class_name => "Email", :foreign_key => "from_address_id"
  has_and_belongs_to_many :emails_received, :class_name => "Email", :join_table => "to_addresses_emails"
end
