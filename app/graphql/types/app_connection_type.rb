# TODO: Factor out common stuff between this and EmailConnectionType
class Types::AppConnectionType < GraphQL::Types::Relay::BaseConnection
  field :total_count, Integer, null: false
  field :nodes, [Types::AppType], null: true

  def total_count
    object.nodes.size
  end
end
