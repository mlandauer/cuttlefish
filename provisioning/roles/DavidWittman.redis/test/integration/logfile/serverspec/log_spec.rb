require 'spec_helper'

describe 'Redis' do
  describe service('redis_6379') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(6379) do
    it { should be_listening.with('tcp') }
  end

  describe file('/var/log/redis.log') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:size) { should > 0 }
  end

  describe file('/var/log') do
    it { should be_directory }
    it { should_not be_owned_by('redis') }
  end
end
