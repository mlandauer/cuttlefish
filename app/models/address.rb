# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :emails_sent, class_name: "Email", foreign_key: "from_address_id"
  has_many :deliveries
  has_many :postfix_log_lines, through: :deliveries
  has_many :emails_received, through: :deliveries, source: :email

  extend FriendlyId
  friendly_id :text

  # Extract just the domain part of the address
  def domain
    text.split("@")[1]
  end

  def emails
    Email.joins(:from_address, :to_addresses)
         .where("addresses.id = ? OR deliveries.address_id = ?", id, id)
  end

  def status
    most_recent_log_line = postfix_log_lines.order("time DESC").first
    most_recent_log_line ? most_recent_log_line.status : "sent"
  end
end
