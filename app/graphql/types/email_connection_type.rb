class Types::EmailConnectionType < Types::BaseObject
  field :total_count, Integer, null: false
  field :nodes, [Types::EmailType], null: true
end
