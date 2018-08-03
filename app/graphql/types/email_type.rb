class Types::EmailType < Types::BaseObject
  field :id, ID, null: false
  field :from, String, null: true
  field :to, String, null: false
  def to
    address.text
  end

  field :subject, String, null: true
  def subject
    email.subject
  end

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
    delivery_links.any?{|delivery_link| delivery_link.clicked?}
  end
  field :logs, [Types::LogType], null: false
  def logs
    object.postfix_log_lines
  end
  field :open_events, [Types::OpenEventType], null: false
  field :click_events, [Types::ClickEventType], null: false

  def self.authorized?(object, context)
    context[:current_admin] &&
      pundit_authorized?(context[:current_admin], object, :show?)
  end

  private

  def email
    BatchLoader.for(object.email_id).batch do |email_ids, loader|
      Email.where(id: email_ids).each { |email| loader.call(email.id, email) }
    end
  end

  def address
    BatchLoader.for(object.address_id).batch do |address_ids, loader|
      Address.where(id: address_ids).each { |address| loader.call(address.id, address) }
    end
  end

  def delivery_links
    BatchLoader.for(object.id).batch(default_value: []) do |delivery_ids, loader|
      DeliveryLink.where(delivery_id: delivery_ids).each do |delivery_link|
        loader.call(delivery_link.delivery_id) { |memo| memo << delivery_link }
      end
    end
  end
end
