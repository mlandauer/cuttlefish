class ClickEvent < ActiveRecord::Base
  belongs_to :delivery_link, counter_cache: true
  delegate :link, to: :delivery_link
  include UserAgent

  alias_method :ua_family, :calculate_ua_family
  alias_method :ua_version, :calculate_ua_version
  alias_method :os_family, :calculate_os_family
  alias_method :os_version, :calculate_os_version

  def url
    link.url
  end
end
