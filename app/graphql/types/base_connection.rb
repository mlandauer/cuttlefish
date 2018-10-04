# frozen_string_literal: true

module Types
  class BaseConnection < GraphQL::Schema::Object
    field :total_count, Integer,
          null: false,
          description: "The total count of items"

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
end
