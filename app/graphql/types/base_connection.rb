class Types::BaseConnection < GraphQL::Schema::Object
  field :total_count, Integer, null: false, description: "The total count of items"
  field :nodes, [Types::Email], null: true, description: "A list of nodes"

  def total_count
    object[:all].count
  end

  def nodes
    limit = [object[:limit], MAX_LIMIT].min
    object[:all].offset(object[:offset]).limit(limit)
  end

  # Limit can never be bigger than 50
  MAX_LIMIT = 50
end
