# frozen_string_literal: true

class DeliveryLink < ApplicationRecord
  belongs_to :link
  belongs_to :delivery
  has_many :click_events, dependent: :destroy

  delegate :to, :subject, :app_name, to: :delivery

  delegate :url, to: :link

  def add_click_event(request)
    click_events.create!(
      user_agent: request.env["HTTP_USER_AGENT"],
      referer: request.referer,
      ip: request.remote_ip
    )
  end

  def clicked?
    !click_events.empty?
  end
end
