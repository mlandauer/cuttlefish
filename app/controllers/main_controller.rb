class MainController < ApplicationController
  def index
  end

  def status_counts
    render partial: "status_counts"
  end

  def reputation
    if request.xhr?
      render partial: "reputation"
      return
    end
  end

end
