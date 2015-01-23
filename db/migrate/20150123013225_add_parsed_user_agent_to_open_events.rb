class AddParsedUserAgentToOpenEvents < ActiveRecord::Migration
  def change
    add_column :open_events, :ua_family, :string
    add_column :open_events, :ua_version, :string
    add_column :open_events, :os_family, :string
    add_column :open_events, :os_version, :string

    parser = UserAgentParser::Parser.new(patterns_path: "lib/regexes.yaml")
    OpenEvent.reset_column_information
    # Resaving open events so that the user agent parsing happens
    count = 0
    OpenEvent.find_each do |open_event|
      parsed_user_agent = parser.parse(open_event.user_agent)

      calculate_ua_family = parsed_user_agent.family
      calculate_ua_version = parsed_user_agent.version.to_s if parsed_user_agent.version
      calculate_os_family = parsed_user_agent.os.family
      calculate_os_version = parsed_user_agent.os.version.to_s if parsed_user_agent.os.version

      open_event.update_attributes(
        ua_family: calculate_ua_family,
        ua_version: calculate_ua_version,
        os_family: calculate_os_family,
        os_version: calculate_os_version
      )

      count += 1
      p count if count % 100 == 0
    end
  end
end
