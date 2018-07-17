class Types::EmailType < Types::BaseObject
  field :subject, String, null: true
  field :received_at, Types::DateTimeType, null: true
end
