class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :email_address
end
