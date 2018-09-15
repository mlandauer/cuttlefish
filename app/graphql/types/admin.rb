class Types::Admin < GraphQL::Schema::Object
  description "An administrator"

  field :id, ID, null: false, description: "The database ID"
  field :email, String, null: false, description: "Their email address"
  field :name, String, null: true, description: "Their full name"
  field :display_name, String, null: false, description: "The name if it's available, otherwise the email"
  field :invitation_created_at, Types::DateTime, null: true, description: "When an invitation to this admin was created"
  field :invitation_accepted_at, Types::DateTime, null: true, description: "When an invitation to this admin was accepted"
  field :current_admin, Boolean, null: false, description: "Whether this is the current admin"
  field :permissions, Types::AdminPermissions, null: false, description: "Permissions for current admin for accessing and editing this Admin" do
    # Permissions should be always accessible even on apps that you can't show
    guard ->(obj, args, ctx) { true }
  end

  def current_admin
    context[:current_admin] == object
  end

  def permissions
    AdminPolicy.new(context[:current_admin], object)
  end
end
