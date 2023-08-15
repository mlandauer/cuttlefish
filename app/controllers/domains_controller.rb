# frozen_string_literal: true

class DomainsController < ApplicationController
  def index
    result = api_query since: 1.week.ago.utc.iso8601
    @data = result.data
  end
end
