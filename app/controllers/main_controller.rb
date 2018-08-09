class MainController < ApplicationController
  def index
  end

  def status_counts
    @deliveries_today = policy_scope(Delivery).today
    @deliveries_this_week = policy_scope(Delivery).this_week
    render partial: "status_counts", locals: { loading: false }
  end

  def reputation
    if request.xhr?
      render partial: "reputation"
      return
    end
  end

end
