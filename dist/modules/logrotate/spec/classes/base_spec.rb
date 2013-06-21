require 'spec_helper'

describe 'logrotate::base' do
  it do
    should contain_package('logrotate').with_ensure('latest')

    should contain_file('/etc/logrotate.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
      'source'  => 'puppet:///modules/logrotate/etc/logrotate.conf',
      'require' => 'Package[logrotate]',
    })

    should contain_file('/etc/logrotate.d').with({
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'require' => 'Package[logrotate]',
    })

    should contain_file('/etc/cron.daily/logrotate').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0555',
      'source'  => 'puppet:///modules/logrotate/etc/cron.daily/logrotate',
      'require' => 'Package[logrotate]',
    })
  end

  context 'on Debian' do
    let(:facts) { {:osfamily => 'Debian'} }

    it { should include_class('logrotate::defaults::debian') }
  end

  context 'on RedHat' do
    let(:facts) { {:osfamily => 'RedHat'} }

    it { should include_class('logrotate::defaults::redhat') }
  end

  context 'on SuSE' do
    let(:facts) { {:osfamily => 'SuSE'} }

    it { should include_class('logrotate::defaults::suse') }
  end

  context 'on Gentoo' do
    let(:facts) { {:operatingsystem => 'Gentoo'} }

    it { should_not include_class('logrotate::defaults::debian') }
    it { should_not include_class('logrotate::defaults::redhat') }
    it { should_not include_class('logrotate::defaults::suse') }
  end
end
