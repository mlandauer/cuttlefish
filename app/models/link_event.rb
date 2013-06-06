class LinkEvent < ActiveRecord::Base
  belongs_to :delivery_link
  delegate :link, to: :delivery_link

  def url
    link.url
  end
end
