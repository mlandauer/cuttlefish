class Types::EmailStatsType < Types::BaseObject
  description "Statistics over a set of emails"
  field :sent_count, Int, null: false, description: "Number of emails sent but not yet delivered or bounced"
  field :delivered_count, Int, null: false, description: "Number of emails delivered"
  field :soft_bounce_count, Int, null: false, description: "Number of emails that soft bounced"
  field :hard_bounce_count, Int, null: false, description: "Number of emails that hard bounced"
  field :not_sent_count, Int, null: false, description: "Number of emails not sent because of the blacklist"
  field :open_rate, Float, null: true, description: "Fraction of emails opened"
  field :click_rate, Float, null: true, description: "Fraction of emails with links that were clicked"

  # TODO: Rename this to "in_flight"
  def sent_count
    status_counts["sent"] || 0
  end

  def delivered_count
    status_counts["delivered"] || 0
  end

  def soft_bounce_count
    status_counts["soft_bounce"] || 0
  end

  def hard_bounce_count
    status_counts["hard_bounce"] || 0
  end

  def not_sent_count
    status_counts["not_sent"] || 0
  end

  def open_rate
    Delivery.open_rate(object)
  end

  def click_rate
    Delivery.click_rate(object)
  end

  private

  def status_counts
    object.group("deliveries.status").count
  end
end
