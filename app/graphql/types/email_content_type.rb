class Types::EmailContentType < Types::BaseObject
  field :text, String, null: false
  field :html, String, null: false
  field :source, String, null: false
end
