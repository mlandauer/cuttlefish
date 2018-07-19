class Types::OpenEventType < Types::BaseObject
  field :created_at, Types::DateTimeType, null: true
  # TODO: Group these two together
  field :ua_family, String, null: true
  field :ua_version, String, null: true
  # TODO: Group these two together
  field :os_family, String, null: true
  field :os_version, String, null: true
  field :ip, String, null: true
end
