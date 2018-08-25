class Types::EmailConnection < Types::Base::Object
  description "A list of Emails"
  field :total_count, Integer, null: false, description: "The total count of items"
  field :nodes, [Types::Email], null: true, description: "A list of nodes"
  field :statistics, Types::EmailStats, null: false, description: "Statistics over emails (ignoring pagination)"

  def total_count
    object[:all].count
  end

  def nodes
    limit = [object[:limit], MAX_LIMIT].min
    object[:all].order(object[:order]).offset(object[:offset]).limit(limit)
  end

  def statistics
    object[:all]
  end

  # Limit can never be bigger than 50
  MAX_LIMIT = 50
end
