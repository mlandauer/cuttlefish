# frozen_string_literal: true

module Types
  class MutationType < GraphQL::Schema::Object
    # TODO: Provide descriptions for these mutations

    field :create_emails, mutation: Mutations::CreateEmails do
      description "Create and send emails"
      guard(lambda do |_object, args, context|
        app = ::App.find_by_id(args["appId"])
        !context[:current_admin].nil? &&
          app &&
          AppPolicy.new(context[:current_admin], app).show? &&
          DeliveryPolicy.new(context[:current_admin], Delivery).create?
      end)
    end

    field :invite_admin_to_team,
          mutation: Mutations::InviteAdminToTeam,
          description: "Invite a new team member by email"
    field :remove_admin,
          mutation: Mutations::RemoveAdmin,
          description: "Remove an admin from your team"
    field :remove_blocked_address,
          mutation: Mutations::RemoveBlockedAddress,
          description:
            "Remove a blocked email address so that email will get delivered " \
            "to that address again"
    field :create_app,
          mutation: Mutations::CreateApp,
          description: "Create an app"
    field :update_app,
          mutation: Mutations::UpdateApp,
          description: "Update an app"
    field :remove_app,
          mutation: Mutations::RemoveApp,
          description: "Remove an app"
    field :upgrade_app_dkim,
          mutation: Mutations::UpgradeAppDkim,
          description: "For a particular app upgrade the dkim selector"
  end
end
