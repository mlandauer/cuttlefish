module DeliveriesHelper
  def canonical_deliveries_path(app, status, search)
    if app
      app_deliveries_path(app, status: status, search: search)
    else
      deliveries_path(status: status, search: search)
    end
  end
end
