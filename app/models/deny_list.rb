# frozen_string_literal: true

class DenyList < ActiveRecord::Base
  belongs_to :team
  belongs_to :address
  belongs_to :caused_by_delivery, class_name: "Delivery"

  def caused_by_postfix_log_line
    caused_by_delivery.postfix_log_lines.first if caused_by_delivery
  end
end
