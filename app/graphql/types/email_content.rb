# frozen_string_literal: true

module Types
  class EmailContent < GraphQL::Schema::Object
    description "The full content of an email"
    field :text, String, null: true, description: "The plain text part of the email"
    field :html, String, null: true, description: "The html part of the email"
    field :source, String, null: false, description: "The full source of the email content"
  end
end
