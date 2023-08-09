# frozen_string_literal: true

class ClickEvent < ApplicationRecord
  # TODO: IMPORTANT Remove optional: true
  belongs_to :delivery_link, counter_cache: true, optional: true
  delegate :link, to: :delivery_link
  include UserAgent

  delegate :url, to: :link
end
