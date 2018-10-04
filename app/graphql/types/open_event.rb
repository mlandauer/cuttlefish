# frozen_string_literal: true

module Types
  class OpenEvent < GraphQL::Schema::Object
    implements Types::UserAgentEvent

    description "Information about someone opening an email"
  end
end
