class Types::EmailContentType < Types::BaseObject
  field :text, String, null: true
  field :html, String, null: true
  field :source, String, null: false
end
