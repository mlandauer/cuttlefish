class MainController < ApplicationController
  def index
  end

  def status_counts
    @stats_today = Delivery.stats(policy_scope(Delivery).today)
    @stats_this_week = Delivery.stats(policy_scope(Delivery).this_week)
    render partial: "status_counts", locals: { loading: false }
  end

  def reputation
    if request.xhr?
      render partial: "reputation"
      return
    end
  end

end
