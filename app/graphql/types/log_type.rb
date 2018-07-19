class Types::LogType < Types::BaseObject
  field :time, Types::DateTimeType, null: false
  field :dsn, String, null: false
  field :extended_status, String, null: false
end
