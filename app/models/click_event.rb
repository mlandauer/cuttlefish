# frozen_string_literal: true

class ClickEvent < ActiveRecord::Base
  belongs_to :delivery_link, counter_cache: true
  delegate :link, to: :delivery_link
  include UserAgent

  def url
    link.url
  end
end
