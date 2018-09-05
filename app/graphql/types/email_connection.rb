class Types::EmailConnection < Types::BaseConnection
  description "A list of Emails"
  field :statistics, Types::EmailStats, null: false, description: "Statistics over emails (ignoring pagination)"

  def statistics
    # Remove the order so that we keep postgres happy
    object[:all].reorder(nil)
  end
end
