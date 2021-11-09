# frozen_string_literal: true

class Link < ApplicationRecord
  has_many :click_events, through: :delivery_links
  has_many :delivery_links
  has_many :deliveries, through: :delivery_links
end
