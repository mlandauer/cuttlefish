class ClientsController < ApplicationController
  def index
    @client_counts = policy_scope(Delivery).joins(:open_events).group(:ua_family).order("count_all desc").count
  end
end
