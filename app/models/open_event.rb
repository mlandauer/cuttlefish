# frozen_string_literal: true

class OpenEvent < ApplicationRecord
  belongs_to :delivery, counter_cache: true
  include UserAgent

  before_save :parse_user_agent!

  def parse_user_agent!
    self.ua_family = calculate_ua_family
    self.ua_version = calculate_ua_version
    self.os_family = calculate_os_family
    self.os_version = calculate_os_version
  end
end
