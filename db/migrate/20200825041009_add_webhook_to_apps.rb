class AddWebhookToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :webhook_url, :string
    add_column :apps, :webhook_key, :string
    App.reset_column_information
    App.find_each do |app|
      app.set_webhook_key
      # If any of the DNS records have changed since the app was
      # initially setup the validation will fail. We don't want this
      # to happen. So, ignore validation.
      app.save!(validate: false)
    end
    change_column_null :apps, :webhook_key, false
  end
end
