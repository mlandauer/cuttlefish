module UserAgent
  def calculate_ua_family
    parsed_user_agent.family
  end

  def calculate_ua_version
    v = parsed_user_agent.version
    v.to_s if v
  end

  def calculate_os_family
    parsed_user_agent.os.family
  end

  def calculate_os_version
    v = parsed_user_agent.os.version
    v.to_s if v
  end

  alias_method :ua_family, :calculate_ua_family
  alias_method :ua_version, :calculate_ua_version
  alias_method :os_family, :calculate_os_family
  alias_method :os_version, :calculate_os_version

  private

  def parsed_user_agent
    @parsed_user_agent ||= user_agent_parser.parse(user_agent)
  end

  # Cache this between requests so that we don't keep reloading the user agent database
  # TODO Put in a PR to the main project to update the default regexes with the google image proxy
  def user_agent_parser
    @@user_agent_parser ||= UserAgentParser::Parser.new(patterns_path: "lib/regexes.yaml")
  end
end
