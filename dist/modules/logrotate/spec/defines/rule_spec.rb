require 'spec_helper'

describe 'logrotate::rule' do
  context 'with an alphanumeric title' do
    let(:title) { 'test' }

    context 'and ensure => absent' do
      let(:params) { {:ensure => 'absent'} }

      it do
        should contain_file('/etc/logrotate.d/test').with_ensure('absent')
      end
    end

    let(:params) { {:path => '/var/log/foo.log'} }
    it do
      should include_class('logrotate::base')
      should contain_file('/etc/logrotate.d/test').with({
        'owner'   => 'root',
        'group'   => 'root',
        'ensure'  => 'present',
        'mode'    => '0444',
      }).with_content("/var/log/foo.log {\n}\n")
    end

    context 'with an array path' do
      let (:params) { {:path => ['/var/log/foo1.log','/var/log/foo2.log']} }
        it do
          should contain_file('/etc/logrotate.d/test').with_content(
            "/var/log/foo1.log /var/log/foo2.log {\n}\n"
          )
        end
    end

    ###########################################################################
    # COMPRESS
    context 'and compress => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :compress => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  compress$/)
      end
    end

    context 'and compress => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :compress => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nocompress$/)
      end
    end

    context 'and compress => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :compress => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /compress must be a boolean/)
      end
    end

    ###########################################################################
    # COMPRESSCMD
    context 'and compresscmd => bzip2' do
      let(:params) {
        {:path => '/var/log/foo.log', :compresscmd => 'bzip2'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  compresscmd bzip2$/)
      end
    end

    ###########################################################################
    # COMPRESSEXT
    context 'and compressext => .bz2' do
      let(:params) {
        {:path => '/var/log/foo.log', :compressext => '.bz2'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  compressext .bz2$/)
      end
    end

    ###########################################################################
    # COMPRESSOPTIONS
    context 'and compressoptions => -9' do
      let(:params) {
        {:path => '/var/log/foo.log', :compressoptions => '-9'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  compressoptions -9$/)
      end
    end

    ###########################################################################
    # COPY
    context 'and copy => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :copy => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test').with_content(/^  copy$/)
      end
    end

    context 'and copy => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :copy => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test').with_content(/^  nocopy$/)
      end
    end

    context 'and copy => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :copy => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /copy must be a boolean/)
      end
    end

    ###########################################################################
    # COPYTRUNCATE
    context 'and copytruncate => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :copytruncate => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  copytruncate$/)
      end
    end

    context 'and copytruncate => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :copytruncate => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nocopytruncate$/)
      end
    end

    context 'and copytruncate => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :copytruncate => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /copytruncate must be a boolean/)
      end
    end

    ###########################################################################
    # CREATE / CREATE_MODE / CREATE_OWNER / CREATE_GROUP
    context 'and create => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :create => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  create$/)
      end

      context 'and create_mode => 0777' do
        let(:params) {
          {
            :path        => '/var/log/foo.log',
            :create      => true,
            :create_mode => '0777',
          }
        }

        it do
          should contain_file('/etc/logrotate.d/test') \
            .with_content(/^  create 0777$/)
        end

        context 'and create_owner => www-data' do
          let(:params) {
            {
              :path         => '/var/log/foo.log',
              :create       => true,
              :create_mode  => '0777',
              :create_owner => 'www-data',
            }
          }

          it do
            should contain_file('/etc/logrotate.d/test') \
              .with_content(/^  create 0777 www-data/)
          end

          context 'and create_group => admin' do
            let(:params) {
              {
                :path         => '/var/log/foo.log',
                :create       => true,
                :create_mode  => '0777',
                :create_owner => 'www-data',
                :create_group => 'admin',
              }
            }

            it do
              should contain_file('/etc/logrotate.d/test') \
                .with_content(/^  create 0777 www-data admin$/)
            end
          end
        end

        context 'and create_group => admin' do
          let(:params) {
            {
              :path         => '/var/log/foo.log',
              :create       => true,
              :create_mode  => '0777',
              :create_group => 'admin',
            }
          }

          it do
            expect {
              should contain_file('/etc/logrotate.d/test')
            }.to raise_error(Puppet::Error, /create_group requires create_owner/)
          end
        end
      end

      context 'and create_owner => www-data' do
        let(:params) {
          {
            :path         => '/var/log/foo.log',
            :create       => true,
            :create_owner => 'www-data',
          }
        }

        it do
          expect {
            should contain_file('/etc/logrotate.d/test')
          }.to raise_error(Puppet::Error, /create_owner requires create_mode/)
        end
      end
    end

    context 'and create => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :create => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nocreate$/)
      end

      context 'and create_mode => 0777' do
        let(:params) {
          {
            :path        => '/var/log/foo.log',
            :create      => false,
            :create_mode => '0777',
          }
        }

        it do
          expect {
            should contain_file('/etc/logrotate.d/test')
          }.to raise_error(Puppet::Error, /create_mode requires create/)
        end
      end
    end

    context 'and create => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :create => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /create must be a boolean/)
      end
    end

    ###########################################################################
    # DATEEXT
    context 'and dateext => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :dateext => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  dateext$/)
      end
    end

    context 'and dateext => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :dateext => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nodateext$/)
      end
    end

    context 'and dateext => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :dateext => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /dateext must be a boolean/)
      end
    end

    ###########################################################################
    # DATEFORMAT
    context 'and dateformat => -%Y%m%d' do
      let(:params) {
        {:path => '/var/log/foo.log', :dateformat => '-%Y%m%d'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  dateformat -%Y%m%d$/)
      end
    end

    ###########################################################################
    # DELAYCOMPRESS
    context 'and delaycompress => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :delaycompress => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  delaycompress$/)
      end
    end

    context 'and delaycompress => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :delaycompress => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nodelaycompress$/)
      end
    end

    context 'and delaycompress => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :delaycompress => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /delaycompress must be a boolean/)
      end
    end

    ###########################################################################
    # EXTENSION
    context 'and extension => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :extension => '.foo'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  extension \.foo$/)
      end
    end

    ###########################################################################
    # IFEMPTY
    context 'and ifempty => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :ifempty => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  ifempty$/)
      end
    end

    context 'and ifempty => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :ifempty => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  notifempty$/)
      end
    end

    context 'and ifempty => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :ifempty => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /ifempty must be a boolean/)
      end
    end

    ###########################################################################
    # MAIL / MAILFIRST / MAILLAST
    context 'and mail => test.example.com' do
      let(:params) {
        {:path => '/var/log/foo.log', :mail => 'test@example.com'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  mail test@example.com$/)
      end

      context 'and mailfirst => true' do
        let(:params) {
          {
            :path      => '/var/log/foo.log',
            :mail      => 'test@example.com',
            :mailfirst => true,
          }
        }

        it do
          should contain_file('/etc/logrotate.d/test') \
            .with_content(/^  mailfirst$/)
        end

        context 'and maillast => true' do
          let(:params) {
            {
              :path      => '/var/log/foo.log',
              :mail      => 'test@example.com',
              :mailfirst => true,
              :maillast  => true,
            }
          }

          it do
            expect {
              should contain_file('/etc/logrotate.d/test')
            }.to raise_error(Puppet::Error, /set both mailfirst and maillast/)
          end
        end
      end

      context 'and maillast => true' do
        let(:params) {
          {
            :path     => '/var/log/foo.log',
            :mail     => 'test@example.com',
            :maillast => true,
          }
        }

        it do
          should contain_file('/etc/logrotate.d/test') \
            .with_content(/^  maillast$/)
        end
      end
    end

    context 'and mail => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :mail => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nomail$/)
      end
    end

    ###########################################################################
    # MAXAGE
    context 'and maxage => 3' do
      let(:params) {
        {:path => '/var/log/foo.log', :maxage => 3}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  maxage 3$/)
      end
    end

    context 'and maxage => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :maxage => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /maxage must be an integer/)
      end
    end

    ###########################################################################
    # MINSIZE
    context 'and minsize => 100' do
      let(:params) {
        {:path => '/var/log/foo.log', :minsize => 100}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  minsize 100$/)
      end
    end

    context 'and minsize => 100k' do
      let(:params) {
        {:path => '/var/log/foo.log', :minsize => '100k'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  minsize 100k$/)
      end
    end

    context 'and minsize => 100M' do
      let(:params) {
        {:path => '/var/log/foo.log', :minsize => '100M'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  minsize 100M$/)
      end
    end

    context 'and minsize => 100G' do
      let(:params) {
        {:path => '/var/log/foo.log', :minsize => '100G'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  minsize 100G$/)
      end
    end

    context 'and minsize => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :minsize => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /minsize must match/)
      end
    end

    ###########################################################################
    # MISSINGOK
    context 'and missingok => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :missingok => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  missingok$/)
      end
    end

    context 'and missingok => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :missingok => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nomissingok$/)
      end
    end

    context 'and missingok => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :missingok => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /missingok must be a boolean/)
      end
    end

    ###########################################################################
    # OLDDIR
    context 'and olddir => /var/log/old' do
      let(:params) {
        {:path => '/var/log/foo.log', :olddir => '/var/log/old'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  olddir \/var\/log\/old$/)
      end
    end

    context 'and olddir => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :olddir => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  noolddir$/)
      end
    end

    ###########################################################################
    # POSTROTATE
    context 'and postrotate => /bin/true' do
      let(:params) {
        {:path => '/var/log/foo.log', :postrotate => '/bin/true'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/postrotate\n    \/bin\/true\n  endscript/)
      end
    end

    ###########################################################################
    # PREROTATE
    context 'and prerotate => /bin/true' do
      let(:params) {
        {:path => '/var/log/foo.log', :prerotate => '/bin/true'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/prerotate\n    \/bin\/true\n  endscript/)
      end
    end

    ###########################################################################
    # FIRSTACTION
    context 'and firstaction => /bin/true' do
      let(:params) {
        {:path => '/var/log/foo.log', :firstaction => '/bin/true'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/firstaction\n    \/bin\/true\n  endscript/)
      end
    end

    ###########################################################################
    # LASTACTION
    context 'and lastaction => /bin/true' do
      let(:params) {
        {:path => '/var/log/foo.log', :lastaction => '/bin/true'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/lastaction\n    \/bin\/true\n  endscript/)
      end
    end

    ###########################################################################
    # ROTATE
    context 'and rotate => 3' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate => 3}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  rotate 3$/)
      end
    end

    context 'and rotate => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /rotate must be an integer/)
      end
    end

    ###########################################################################
    # ROTATE_EVERY
    context 'and rotate_every => hour' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate_every => 'hour'}
      }

      it { should include_class('logrotate::hourly') }
      it { should contain_file('/etc/logrotate.d/hourly/test') }
    end

    context 'and rotate_every => day' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate_every => 'day'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  daily$/)
      end
    end

    context 'and rotate_every => week' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate_every => 'week'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  weekly$/)
      end
    end

    context 'and rotate_every => month' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate_every => 'month'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  monthly$/)
      end
    end

    context 'and rotate_every => year' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate_every => 'year'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  yearly$/)
      end
    end

    context 'and rotate_every => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :rotate_every => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /invalid rotate_every value/)
      end
    end

    ###########################################################################
    # SIZE
    context 'and size => 100' do
      let(:params) {
        {:path => '/var/log/foo.log', :size => 100}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  size 100$/)
      end
    end

    context 'and size => 100k' do
      let(:params) {
        {:path => '/var/log/foo.log', :size => '100k'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  size 100k$/)
      end
    end

    context 'and size => 100M' do
      let(:params) {
        {:path => '/var/log/foo.log', :size => '100M'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  size 100M$/)
      end
    end

    context 'and size => 100G' do
      let(:params) {
        {:path => '/var/log/foo.log', :size => '100G'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  size 100G$/)
      end
    end

    context 'and size => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :size => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /size must match/)
      end
    end

    ###########################################################################
    # SHAREDSCRIPTS
    context 'and sharedscripts => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :sharedscripts => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  sharedscripts$/)
      end
    end

    context 'and sharedscripts => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :sharedscripts => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  nosharedscripts$/)
      end
    end

    context 'and sharedscripts => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :sharedscripts => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /sharedscripts must be a boolean/)
      end
    end

    ###########################################################################
    # SHRED / SHREDCYCLES
    context 'and shred => true' do
      let(:params) {
        {:path => '/var/log/foo.log', :shred => true}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  shred$/)
      end

      context 'and shredcycles => 3' do
        let(:params) {
          {:path => '/var/log/foo.log', :shred => true, :shredcycles => 3}
        }

        it do
          should contain_file('/etc/logrotate.d/test') \
            .with_content(/^  shredcycles 3$/)
        end
      end

      context 'and shredcycles => foo' do
        let(:params) {
          {:path => '/var/log/foo.log', :shred => true, :shredcycles => 'foo'}
        }

        it do
          expect {
            should contain_file('/etc/logrotate.d/test')
          }.to raise_error(Puppet::Error, /shredcycles must be an integer/)
        end
      end
    end

    context 'and shred => false' do
      let(:params) {
        {:path => '/var/log/foo.log', :shred => false}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  noshred$/)
      end
    end

    context 'and shred => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :shred => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /shred must be a boolean/)
      end
    end

    ###########################################################################
    # START
    context 'and start => 0' do
      let(:params) {
        {:path => '/var/log/foo.log', :start => 0}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  start 0$/)
      end
    end

    context 'and start => foo' do
      let(:params) {
        {:path => '/var/log/foo.log', :start => 'foo'}
      }

      it do
        expect {
          should contain_file('/etc/logrotate.d/test')
        }.to raise_error(Puppet::Error, /start must be an integer/)
      end
    end

    ###########################################################################
    # UNCOMPRESSCMD
    context 'and uncompresscmd => bunzip2' do
      let(:params) {
        {:path => '/var/log/foo.log', :uncompresscmd => 'bunzip2'}
      }

      it do
        should contain_file('/etc/logrotate.d/test') \
          .with_content(/^  uncompresscmd bunzip2$/)
      end
    end
  end

  context 'with a non-alphanumeric title' do
    let(:title) { 'foo bar' }
    let(:params) {
      {:path => '/var/log/foo.log'}
    }

    it do
      expect {
        should contain_file('/etc/logrotate.d/foo bar')
      }.to raise_error(Puppet::Error, /namevar must be alphanumeric/)
    end
  end
end
