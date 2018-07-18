class Types::EmailType < Types::BaseObject
  field :id, ID, null: false
  field :from, String, null: true
  field :to, String, null: false
  field :subject, String, null: true
  field :data, String, null: true
  field :text_part, String, null: true
  field :html_part, String, null: true
  field :created_at, Types::DateTimeType, null: false

  field :app, Types::AppType, null: true
  field :status, Types::StatusType, null: false
end
