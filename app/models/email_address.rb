class EmailAddress < ActiveRecord::Base
  has_many :emails_sent, :class_name => "Email", :foreign_key => "from_address_id"
end
