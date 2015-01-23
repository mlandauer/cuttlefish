class AddParsedUserAgentToOpenEvents < ActiveRecord::Migration
  def change
    add_column :open_events, :ua_family, :string
    add_column :open_events, :ua_version, :string
    add_column :open_events, :os_family, :string
    add_column :open_events, :os_version, :string

    OpenEvent.reset_column_information
    # Resaving open events so that the user agent parsing happens
    OpenEvent.find_each(batch_size: 500) do |open_event|
      open_event.save!
    end
  end
end
