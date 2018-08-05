class BlackList < ActiveRecord::Base
  belongs_to :team
  belongs_to :address
  belongs_to :caused_by_delivery, class_name: "Delivery"

  def has_record_of_cause?
    caused_by_delivery.present? && caused_by_delivery.subject.present?
  end
end
