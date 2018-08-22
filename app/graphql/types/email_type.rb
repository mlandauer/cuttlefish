class Types::EmailType < Types::Base::Object
  description "An email delivered to a single destination"
  guard ->(object, args, context) {
    context[:current_admin] &&
      DeliveryPolicy.new(context[:current_admin], object.object).show?
  }

  field :id, ID, null: false, description: "The database ID of the email"
  field :from, String, null: true, description: "The email address which this email is from"
  field :to, String, null: false, description: "The destination email address"
  field :subject, String, null: true, description: "The subject of this email"
  field :content, Types::EmailContentType, null: true, description: "The full content of this email (if it is available)"
  field :created_at, Types::DateTimeType, null: false, description: "When the email was received by Cuttlefish"
  field :app, Types::AppType, null: true, description: "The app associated with this email"
  field :status, Types::StatusType, null: false, description: "The status of this email"
  field :opened, Boolean, null: false, description: "Whether this email was opened"
  field :clicked, Boolean, null: false, description: "Whether this email was clicked"
  field :delivery_events, [Types::DeliveryEventType], null: false, description: "A list of delivery events for this email"
  field :open_events, [Types::OpenEventType], null: false, description: "A list of open events for this email"
  field :click_events, [Types::ClickEventType], null: false, description: "A list of click events for this email"

  def to
    address.text
  end

  def subject
    email.subject
  end

  def content
    if object.data
      { text: object.text_part, html: object.html_part, source: object.data }
    end
  end

  def opened
    object.opened?
  end

  def clicked
    object.delivery_links.any?{|delivery_link| delivery_link.clicked?}
  end

  def delivery_events
    object.postfix_log_lines
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
