require 'spec_helper'

describe 'logrotate::defaults::debian' do
  it do
    should contain_logrotate__rule('wtmp').with({
      'rotate_every' => 'month',
      'rotate'       => '1',
      'create'       => true,
      'create_mode'  => '0664',
      'create_owner' => 'root',
      'create_group' => 'utmp',
      'missingok'    => true,
    })

    should contain_logrotate__rule('btmp').with({
      'rotate_every' => 'month',
      'rotate'       => '1',
      'create'       => true,
      'create_mode'  => '0660',
      'create_owner' => 'root',
      'create_group' => 'utmp',
      'missingok'    => true,
    })
  end
end
