# TODO: Factor out common stuff between this and EmailConnectionType
class Types::AppConnectionType < Types::BaseObject
  field :total_count, Integer, null: false
  field :nodes, [Types::AppType], null: true
end
