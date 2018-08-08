class Types::EmailStatsType < Types::BaseObject
  description "Statistics over a set of emails"
  field :number_created, Int, null: false, description: "Number of emails created"
  field :number_delivered, Int, null: false, description: "Number of emails delivered"
  field :number_soft_bounces, Int, null: false, description: "Number of emails that soft bounced"
  field :number_hard_bounces, Int, null: false, description: "Number of emails that hard bounced"
  field :number_not_sent, Int, null: false, description: "Number of emails not sent because of the blacklist"
  field :open_rate, Float, null: true, description: "Fraction of emails opened"
  field :click_rate, Float, null: true, description: "Fraction of emails with links that were clicked"

  # TODO: This value could easily be confusing. Fix this
  def number_created
    status_counts.values.sum || 0
  end

  def number_delivered
    status_counts["delivered"] || 0
  end

  def number_soft_bounces
    status_counts["soft_bounce"] || 0
  end

  def number_hard_bounces
    status_counts["hard_bounce"] || 0
  end

  def number_not_sent
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
