class Mutations::RemoveAdmin < GraphQL::Schema::Mutation
  # TODO: Give descriptions for arguments and fields
  argument :id, ID, required: true

  field :admin, Types::Admin, null: true

  def resolve(id:)
    remove_admin = ::RemoveAdmin.call(id: id, current_admin: context[:current_admin])
    if remove_admin.success?
      { admin: remove_admin.result }
    else
      raise GraphQL::ExecutionError, remove_admin.message
    end
  end

end
