class OpenEvent < ActiveRecord::Base
  belongs_to :delivery, counter_cache: true

  def ua_family
    parsed_user_agent.family
  end

  def os_family
    parsed_user_agent.os.family
  end

  private

  def parsed_user_agent
    @parsed_user_agent ||= user_agent_parser.parse(user_agent)
  end

  # Cache this between requests so that we don't keep reloading the user agent database
  def user_agent_parser
    @@user_agent_parser ||= UserAgentParser::Parser.new
  end
end
