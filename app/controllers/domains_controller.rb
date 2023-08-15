# frozen_string_literal: true

class DomainsController < ApplicationController
  def index
    result = api_query since: 1.week.ago.utc.iso8601
    @data = result.data
    # Going to do a little rejigging of the data
    hard_bounce_counts = @data.emails.statistics.hard_bounce_count_by_to_domain.map{|c| [c.name, c.count]}.to_h
    delivered_counts = @data.emails.statistics.delivered_count_by_to_domain.map{|c| [c.name, c.count]}.to_h
    @domains = hard_bounce_counts.map do |domain, hard_bounces|
      {
        domain: domain,
        hard_bounces: hard_bounces,
        deliveries: (delivered_counts[domain] || 0)
      }
    end
  end
end
