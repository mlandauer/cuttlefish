require 'spec_helper'

describe 'Redis' do
  describe service('sentinel_26379') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(26379) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe file('/etc/redis/sentinel_26379.conf') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:content) { should match /port 26379/ }
  end

  describe file('/var/run/redis/sentinel_26379.pid') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:size) { should > 0 }
  end
end
