class Types::EmailConnection < Types::BaseConnection
  description "A list of Emails"
  field :statistics, Types::EmailStats, null: false, description: "Statistics over emails (ignoring pagination)"

  def statistics
    object[:all]
  end
end
