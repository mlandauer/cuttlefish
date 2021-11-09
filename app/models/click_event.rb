# frozen_string_literal: true

class ClickEvent < ApplicationRecord
  belongs_to :delivery_link, counter_cache: true
  delegate :link, to: :delivery_link
  include UserAgent

  delegate :url, to: :link
end
