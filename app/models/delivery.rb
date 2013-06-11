class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }, dependent: :destroy
  has_many :open_events, dependent: :destroy
  has_many :delivery_links, dependent: :destroy
  has_many :link_events, through: :delivery_links

  delegate :app, :from, :from_address, :text_part, :html_part, :data,
    :link_tracking_enabled?, :open_tracking_enabled?, to: :email
  after_save :update_status!
  
  def self.today
    where('created_at > ?', Date.today.beginning_of_day)
  end

  def self.this_week
    where('created_at > ?', 7.days.ago)
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

  def status
    if sent?
      last_line = postfix_log_lines.first
      last_line ? last_line.status : "sent"
    else
      "not_sent"
    end
  end

  def update_status!
    email.update_status!
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
end
