# frozen_string_literal: true

module Types
  class MutationType < GraphQL::Schema::Object
    # TODO: Provide descriptions for these mutations

    field :create_emails, mutation: Mutations::CreateEmails do
      guard(lambda do |_object, args, context|
        app = ::App.find_by_id(args["appId"])
        !context[:current_admin].nil? &&
          app &&
          AppPolicy.new(context[:current_admin], app).show? &&
          DeliveryPolicy.new(context[:current_admin], Delivery).create?
      end)
    end

    field :remove_admin, mutation: Mutations::RemoveAdmin
    field :remove_blocked_address, mutation: Mutations::RemoveBlockedAddress
    field :create_app, mutation: Mutations::CreateApp
    field :update_app, mutation: Mutations::UpdateApp
    field :remove_app, mutation: Mutations::RemoveApp
    field :upgrade_app_dkim, mutation: Mutations::UpgradeAppDkim
  end
end
