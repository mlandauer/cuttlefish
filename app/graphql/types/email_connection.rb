# frozen_string_literal: true

class Types::EmailConnection < Types::BaseConnection
  description "A list of Emails"
  field :nodes, [Types::Email], null: true, description: "A list of nodes"
  field :statistics, Types::EmailStats, null: false, description: "Statistics over emails (ignoring pagination)"

  def statistics
    # Remove the order so that we keep postgres happy
    object[:all].reorder(nil)
  end
end
