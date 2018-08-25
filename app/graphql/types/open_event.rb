class Types::OpenEvent < GraphQL::Schema::Object
  implements Types::UserAgentEvent

  description "Information about someone opening an email"
end
