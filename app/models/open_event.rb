class OpenEvent < ActiveRecord::Base
  belongs_to :delivery, counter_cache: true
  include UserAgent

  alias_method :ua_family, :calculate_ua_family
  alias_method :ua_version, :calculate_ua_version
  alias_method :os_family, :calculate_os_family
  alias_method :os_version, :calculate_os_version
end
