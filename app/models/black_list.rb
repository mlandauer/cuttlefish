class BlackList < ActiveRecord::Base
  belongs_to :address
  belongs_to :caused_by_delivery, class_name: "Delivery"
end
