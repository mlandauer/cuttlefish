class Link < ActiveRecord::Base
  has_many :click_events, through: :delivery_links
  has_many :delivery_links
end
