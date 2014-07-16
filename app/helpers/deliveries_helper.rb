module DeliveriesHelper
  def canonical_deliveries_path(app, status)
    if app
      app_deliveries_path(app, status: status)
    else
      deliveries_path(status: status)
    end
  end
end
