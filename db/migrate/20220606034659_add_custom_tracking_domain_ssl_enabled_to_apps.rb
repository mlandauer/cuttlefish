class AddCustomTrackingDomainSslEnabledToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :custom_tracking_domain_ssl_enabled, :boolean, null: false, default: false
  end
end
