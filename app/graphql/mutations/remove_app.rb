# frozen_string_literal: true

class Mutations::RemoveApp < Mutations::Base
  # TODO: Give descriptions for arguments and fields
  argument :id, ID, required: true

  field :app, Types::App, null: true
  field :errors, [Types::UserError], null: false

  def resolve(id:)
    destroy = AppServices::Destroy.call(id: id, current_admin: context[:current_admin])
    user_errors = if destroy.success?
      []
    else
      [{
        path: [],
        message: destroy.error.message,
        type: destroy.error.type.to_s.upcase
      }]
    end
    { app: destroy.result, errors: user_errors }
  end

end
