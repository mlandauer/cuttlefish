require 'spec_helper'
describe 'apt::builddep', :type => :define do

  let(:title) { 'my_package' }

  describe "should succeed with a Class['apt']" do
    let(:pre_condition) { 'class {"apt": } ' }

    it { should contain_exec("apt_update").with({
        'command' => "/usr/bin/apt-get update",
        'refreshonly' => true
      })
    }
  end

  describe "should fail without Class['apt']" do
    it { expect {should contain_exec("apt-update-#{title}").with({
        'command' => "/usr/bin/apt-get update",
        'refreshonly' => true
        }).to raise_error(Puppet::Error)
      }
    }
  end

end
