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
  field :opened, Boolean, null: false
  def opened
    object.opened?
  end
  field :clicked, Boolean, null: false
  def clicked
    object.clicked?
  end
  field :logs, [Types::LogType], null: false
  def logs
    object.postfix_log_lines
  end
  field :open_events, [Types::OpenEventType], null: false
  field :click_events, [Types::ClickEventType], null: false
end

# TODO: Fields that still need to be included based on what's shown in the
# admin interface for the delivery#show action

# Delivery:
#   # TODO: Group these together
#   content_available?
#   html_part
#   text_part
#   data
