class AddParsedUserAgentToOpenEvents < ActiveRecord::Migration
  def change
    add_column :open_events, :ua_family, :string
    add_column :open_events, :ua_version, :string
    add_column :open_events, :os_family, :string
    add_column :open_events, :os_version, :string

    OpenEvent.reset_column_information
    # Resaving open events so that the user agent parsing happens
    count = 0
    OpenEvent.find_each(batch_size: 250) do |open_event|
      open_event.update_attributes(
        ua_family: open_event.calculate_ua_family,
        ua_version: open_event,calculate_ua_version,
        os_family: open_event,calculate_os_family,
        os_version: open_event,calculate_os_version
      )

      count += 1
      p count if count % 100 == 0
    end
  end
end
