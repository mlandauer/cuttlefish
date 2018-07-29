class Types::EmailConnectionType < GraphQL::Types::Relay::BaseConnection
  field :total_count, Integer, null: false
  field :nodes, [Types::EmailType], null: true

  def total_count
    object.nodes.size
  end
end
