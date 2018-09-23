class AppForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, String
  attribute :click_tracking_enabled, Boolean, default: true
  attribute :open_tracking_enabled, Boolean, default: true
  attribute :custom_tracking_domain, String
end
