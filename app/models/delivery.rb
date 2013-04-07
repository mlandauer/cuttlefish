class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
end
