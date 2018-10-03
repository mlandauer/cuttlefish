# frozen_string_literal: true

class AddParsedUserAgentToOpenEvents < ActiveRecord::Migration
  # The counter_cache on the association was causing a memory leak even
  # when using OpenEvent.find_each below. So just for this migration use
  # a stripped down version of the model
  class OpenEvent < ActiveRecord::Base
  end

  def change
    add_column :open_events, :ua_family, :string
    add_column :open_events, :ua_version, :string
    add_column :open_events, :os_family, :string
    add_column :open_events, :os_version, :string

    OpenEvent.reset_column_information

    parser = UserAgentParser::Parser.new(patterns_path: "lib/regexes.yaml")
    ActiveRecord::Base.uncached do
      OpenEvent.find_each do |open_event|
        parsed_user_agent = parser.parse(open_event.user_agent)

        open_event.ua_family = parsed_user_agent.family
        open_event.ua_version = parsed_user_agent.version.to_s if parsed_user_agent.version
        open_event.os_family = parsed_user_agent.os.family
        open_event.os_version = parsed_user_agent.os.version.to_s if parsed_user_agent.os.version
        open_event.save!
      end
    end
  end
end
