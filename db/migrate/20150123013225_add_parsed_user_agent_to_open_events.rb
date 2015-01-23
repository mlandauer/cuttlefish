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
    ActiveRecord::Base.uncached do
      OpenEvent.find_each do |open_event|
        parsed_user_agent = parser.parse(open_event.user_agent)

        calculate_ua_family = parsed_user_agent.family.to_s.clone
        calculate_ua_version = parsed_user_agent.version.to_s.clone if parsed_user_agent.version
        calculate_os_family = parsed_user_agent.os.family.to_s.clone
        calculate_os_version = parsed_user_agent.os.version.to_s.clone if parsed_user_agent.os.version

        # Avoid calllbacks
        open_event.ua_family = calculate_ua_family
        open_event.ua_version = calculate_ua_version
        open_event.os_family = calculate_os_family
        open_event.os_version = calculate_os_version
        open_event.save(validate: false)

        count += 1
        if count % 1000 == 0
          p count
          GC.start
        end
      end
    end
  end
end
