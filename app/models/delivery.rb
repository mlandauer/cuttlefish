class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }, dependent: :destroy, inverse_of: :delivery
  has_many :open_events, dependent: :destroy
  has_many :delivery_links, dependent: :destroy
  has_many :link_events, through: :delivery_links

  delegate :app, :from, :from_address, :text_part, :html_part, :data,
    :link_tracking_enabled?, :open_tracking_enabled?, to: :email

  before_save :update_my_status!

  def self.today
    where('deliveries.created_at > ?', Date.today.beginning_of_day)
  end

  def self.this_week
    where('deliveries.created_at > ?', 7.days.ago)
  end

  # This delivery is being open tracked
  def set_open_tracked!
    update_attributes(open_tracked: true)
  end

  def add_open_event(request)
    open_events.create!(
      user_agent: request.env['HTTP_USER_AGENT'],
      referer: request.referer,
      ip: request.remote_ip
    )
  end

  def calculated_status
    if sent?
      last_line = postfix_log_lines.first
      last_line ? last_line.status : "sent"
    else
      "not_sent"
    end
  end

  def update_my_status!
    self.status = calculated_status
  end

  def to
    address.text
  end

  def opened?
    !open_events.empty?
  end

  def clicked?
    !link_events.empty?
  end

  def app_name
    app.name
  end

  # A value between 0 and 1. The fraction of deliveries with open tracking for which the delivery was opened
  # Returns nil when there are no deliveries with open tracking (which would otherwise cause a division by
  # zero error)
  def self.open_rate(deliveries)
    # By doing an _inner_ join we only end up counting deliveries that have open_events
    # And for those deliveries with multiple open events we don't want to count those several times
    n = deliveries.joins(:open_events).select("distinct(deliveries.id)").count
    total =  deliveries.where(open_tracked: true).count
    (n.to_f / total) if total > 0
  end
end
