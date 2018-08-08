class Types::EmailConnectionType < Types::BaseObject
  description "A list of Emails"
  field :total_count, Integer, null: false, description: "The total count of items"
  field :nodes, [Types::EmailType], null: true, description: "A list of nodes"
  field :statistics, Types::EmailStatsType, null: false, description: "Statistics over emails (ignoring pagination)"
  def statistics
    object[:all]
  end
end
