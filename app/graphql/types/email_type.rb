class Types::EmailType < Types::BaseObject
  field :from, String, null: true
  field :to, String, null: false
  field :subject, String, null: true
  field :data, String, null: true
  field :text_part, String, null: true
  field :html_part, String, null: true
end
