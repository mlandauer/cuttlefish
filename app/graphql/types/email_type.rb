class Types::EmailType < Types::BaseObject
  field :id, ID, null: false
  field :from, String, null: true
  field :to, String, null: false
  field :subject, String, null: true

  field :content, Types::EmailContentType, null: true
  def content
    if object.data
      { text: object.text_part, html: object.html_part, source: object.data }
    end
  end
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

  def self.authorized?(object, context)
    context[:current_admin] && Pundit.authorize(context[:current_admin], object, :show?)
  end
end
