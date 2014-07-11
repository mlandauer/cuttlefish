class AddCounterCacheToDeliveryLinks < ActiveRecord::Migration
  def change
    add_column :delivery_links, :click_events_count, :integer, null: false, default: 0
    # reset cached counts for delivery_links with click_events only
    puts "Collecting ids..."
    ids = Set.new
    ClickEvent.pluck(:delivery_link_id).each {|id| ids << id}
    puts "Reseting counters..."
    ids.each do |id|
      DeliveryLink.reset_counters(id, :click_events)
    end
  end
end
