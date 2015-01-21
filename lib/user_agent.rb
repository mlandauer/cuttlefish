module UserAgent
  def ua_family
    parsed_user_agent.family
  end

  def ua_version
    v = parsed_user_agent.version
    v.to_s if v
  end

  def os_family
    parsed_user_agent.os.family
  end

  def os_version
    v = parsed_user_agent.os.version
    v.to_s if v
  end

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
