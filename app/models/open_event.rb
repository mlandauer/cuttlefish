class OpenEvent < ActiveRecord::Base
  belongs_to :delivery, counter_cache: true

  def ua_family
    user_agent_info["ua_family"]
  end

  def ua_url
    user_agent_info["ua_url"]
  end

  def os_family
    user_agent_info["os_family"]
  end

  def os_url
    user_agent_info["os_url"]
  end

  private

  def user_agents_cache_directory
    "db/user_agents"
  end

  def user_agent_info_without_caching
    # This is really inefficient. It's going to reload the cache on
    # every single web request
    # TODO Make this efficient
    FileUtils::mkdir_p(user_agents_cache_directory)
    uas_parser = UASparser.new(user_agents_cache_directory)
    uas_parser.parse(user_agent)
  end

  def user_agent_info
    @user_agent_info ||= user_agent_info_without_caching
  end
end
