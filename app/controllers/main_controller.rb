class MainController < ApplicationController
  def index
  end

  def status_counts
    result = api_query :status_counts_query,
      since1: 1.day.ago.utc.iso8601, since2: 1.week.ago.utc.iso8601
    @stats_today = result.data.emails1.statistics
    @stats_this_week = result.data.emails2.statistics

    render partial: "status_counts", locals: { loading: false }
  end

  def reputation
    if request.xhr?
      render partial: "reputation"
      return
    end
  end

end
