# frozen_string_literal: true

module Filters
  class Tracking < Filters::Mail
    attr_accessor :tracking_domain, :using_custom_tracking_domain

    def initialize(options)
      @tracking_domain = options[:tracking_domain]
      @using_custom_tracking_domain = options[:using_custom_tracking_domain]
    end

    # Hostname to use for the open tracking image or rewritten link
    def host
      Rails.env.development? ? "localhost:3000" : tracking_domain
    end

    # Whether to use ssl for the open tracking image or rewritten link
    def protocol
      using_custom_tracking_domain || Rails.env.development? ? "http" : "https"
    end
  end
end
