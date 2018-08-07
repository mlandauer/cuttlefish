# TODO: Factor out common stuff between this and EmailConnectionType
class Types::AppConnectionType < Types::BaseObject
  description "A list of Apps"
  field :total_count, Integer, null: false, description: "The total count of items"
  field :nodes, [Types::AppType], null: true, description: "A list of nodes"
end
