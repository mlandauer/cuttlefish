# frozen_string_literal: true

module Types
  class MutationType < GraphQL::Schema::Object
    field :login_admin,
          mutation: Mutations::LoginAdmin,
          description: "Login using a password returning a JSON web token"

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

    field :register_site_admin,
          mutation: Mutations::RegisterSiteAdmin,
          description: "Register the very first admin on the site"
    field :update_admin,
          mutation: Mutations::UpdateAdmin,
          description: "Update account details of the logged in admin"
    field :send_reset_password_instructions,
          mutation: Mutations::SendResetPasswordInstructions,
          description: "Send instructions on how to reset your password by email"
    field :reset_password_by_token,
          mutation: Mutations::ResetPasswordByToken,
          description: "Using token from email, reset your password"
    field :invite_admin_to_team,
          mutation: Mutations::InviteAdminToTeam,
          description: "Invite a new team member by email"
    field :accept_admin_invitation,
          mutation: Mutations::AcceptAdminInvitation,
          description: "Accept an invitation to join, setting a password and name"
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
