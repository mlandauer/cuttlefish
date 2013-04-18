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

  def user_agent_info_without_caching
    # This is really inefficient. It's going to reload the cache on
    # every single web request
    # TODO Make this efficient
    # TODO Put the cache in a more sensible place and make it persistent across deploys
    uas_parser = UASparser.new('db')
    uas_parser.parse(user_agent)
  end

  def user_agent_info
    @user_agent_info ||= user_agent_info_without_caching
  end
end
