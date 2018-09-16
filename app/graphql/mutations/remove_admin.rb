class Mutations::RemoveAdmin < GraphQL::Schema::Mutation
  # TODO: Give descriptions for arguments and fields
  argument :id, ID, required: true

  # We want the errors for a non-existent id and one you don't have permission
  # to access to be the same so that there is no information leakage to clients
  # about which ids are being used
  # Therefore, we might as well just return nil for the admin in these cases.
  # There is little need for fancy return error messages
  field :admin, Types::Admin, null: true

  def resolve(id:)
    remove_admin = ::RemoveAdmin.call(id: id, current_admin: context[:current_admin])
    { admin: remove_admin.result }
  end

end
