require 'puppet/provider/package'
require 'uri'

# Ruby gems support.
Puppet::Type.type(:package).provide :rbenvgem, :parent => Puppet::Provider::Package do
    desc "Ruby Gem support.  If a URL is passed via ``source``, then that URL is used as the
         remote gem repository; if a source is present but is not a valid URL, it will be
         interpreted as the path to a local gem file.  If source is not present at all,
         the gem will be installed from the default gem repositories. An optional version
         of an rbenv managed ruby may be supplied after a / in the name, eg 'bundler/1.9.3-p125'"

    has_feature :versionable

    commands :gemcmd => "/usr/local/bin/rbenv-gem"

    def self.gemcmd(ruby_version)
      #puts "self.gemcmd: ruby_version: #{ruby_version.to_s}"
      case ruby_version
      when nil, '', 'default'
        return command(:gemcmd)
      else
        candidate_versions = rbenv_ruby_versions.grep(/#{ruby_version}/)
        case
        when candidate_versions.length == 0
          puts "yeah i can't see that version of ruby (#{ruby_version}) already installed under rbenv ... I should probably install it but i can't be bothered."
          return nil
        when candidate_versions.length == 1
          puts "beauty, a direct match. we'll use this version: #{ruby_version}"
          rbenv_ruby_version = candidate_versions.first
        when candidate_versions.length > 1
          buffy = "blast, multiple ruby versions match '#{ruby_version}', they are: "
          buffy += "[#{candidate_versions.join(', ')}], picking the last one - #{candidate_versions.last}"
          puts buffy
          rbenv_ruby_version = candidate_versions.last
        end
        pathy = "/opt/rbenv/versions/#{rbenv_ruby_version}/bin/gem"
        File.executable?(pathy) ? result = pathy : result = nil
        puts "gemcmd result: " + result
        result
      end
    end

    def self.rbenv_ruby_versions
      rbenv_versions = Dir.glob('/opt/rbenv/versions/*-p*').map {|path| File.basename(path) }
      puts "rbenv_ruby_versions: #{rbenv_versions.join(', ')}"
      rbenv_versions
    end

    def self.name_split(resource_name)
      gem, ruby_version = resource_name.split('/', 2)
      gem_cmd = self.gemcmd(ruby_version)
      puts "name_split: using gem command: #{gem_cmd}"
      return {:gem => gem, :ruby_version => ruby_version, :gem_cmd => gem_cmd}
    end

    def self.gemlist(hash)
        if hash[:gem_cmd]
          gem_cmd = hash[:gem_cmd]
        else
          gem_cmd = command(:gemcmd)
        end

        command = [gem_cmd, "list"]

        if hash[:local]
            command << "--local"
        else
            command << "--remote"
        end

        if hash[:source]
            command << " --clear-sources --source #{hash[:source]}"
        end

        if name = hash[:justme]
            command << name
        end

        #puts "gemlist: command: #{command.join(' ')}"
        begin
            #testcmd = command.join(' ') + ' 2>&1 ; echo "retval: $?"; echo env: ; env'
            #puts "gemlist: command output: " + execute(testcmd)
            list = execute(command.join(' ')).split("\n").collect do |set|
                if gemhash = gemsplit(set)
                    gemhash[:provider] = :rbenvgem
                    gemhash
                else
                    nil
                end
            end.compact
            #puts "gemlist: list is as follows:"
            #puts list.inspect
        rescue Puppet::ExecutionFailure => detail
            raise Puppet::Error, "Could not list gems: %s" % detail
        end

        if hash[:justme]
            return list.shift
        else
            return list
        end
    end

    def self.gemsplit(desc)
        case desc
        when /^\*\*\*/, /^\s*$/, /^\s+/; return nil
        when /^(\S+)\s+\((.+)\)/
            name = $1
            version = $2.split(/,\s*/)[0]
            return {
                :name => name,
                :ensure => version
            }
        else
            Puppet.warning "Could not match %s" % desc
            nil
        end
    end

    # returns a list of gems installed
    # iterates through all ruby versions managed by rbenv
    # appends the version of ruby to the end of the gem name,
    # eg 'flapjack' under 1.9.3-p125 -> 'flapjack/1.9.3-p125'
    def self.instances(justme = false)
        results = []
        #puts "in self.instances"
        rbenv_ruby_versions.each {|ruby_version|
            #puts "self.instances: ruby_version: #{ruby_version}"
            gem_cmd = "/opt/rbenv/versions/#{ruby_version}/bin/gem"
            results.concat( gemlist(:local => true, :gem_cmd => gem_cmd).collect do |hash|
                hash[:name] = hash[:name] + '/' + ruby_version
                #puts hash.inspect
                new(hash)
            end )
        }
        #puts "at end of self.instances, results:"
        #puts results.inspect
        results
    end

    def install(useversion = true)
        name_split   = self.class.name_split(resource[:name])
        gem          = name_split[:gem]
        gem_cmd      = name_split[:gem_cmd]
        ruby_version = name_split[:ruby_version]

        self.fail("gem_cmd is nil") unless gem_cmd

        command = [gem_cmd, 'install', '--no-rdoc', '--no-ri']
        if (! resource[:ensure].is_a? Symbol) and useversion
            command << "-v" << resource[:ensure]
        end

        if source = resource[:source]
            begin
                uri = URI.parse(source)
            rescue => detail
                fail "Invalid source '%s': %s" % [uri, detail]
            end

            case uri.scheme
            when nil
                # no URI scheme => interpret the source as a local file
                command << source
            when /file/i
                command << uri.path
            when 'puppet'
                # we don't support puppet:// URLs (yet)
                raise Puppet::Error.new("puppet:// URLs are not supported as gem sources")
            else
                # interpret it as a gem repository
                command << "--source" << "#{source}"
            end
        end
        command << gem
        puts "install: command: #{command.join(' ')}"
        output = execute(command)
        # puts "output: #{output}"
        # Apparently some stupid gem versions don't exit non-0 on failure
        if output.include?("ERROR")
            self.fail "Could not install: %s" % output.chomp
        end
    end

    def latest
        name_split   = self.class.name_split(resource[:name])
        source       = resource[:source] || nil
        gem          = name_split[:gem]
        gem_cmd      = name_split[:gem_cmd]
        ruby_version = name_split[:ruby_version]

        # This always gets the latest version available.
        hash = self.class.gemlist(:justme => gem, :gem_cmd => gem_cmd, :source => source)
        #puts "latest: hash: #{hash.inspect}"
        return hash[:ensure]
    end

    def query
        #puts "in query: resource[:name]: " + resource[:name]
        name_split   = self.class.name_split(resource[:name])
        gem          = name_split[:gem]
        gem_cmd      = name_split[:gem_cmd]
        ruby_version = name_split[:ruby_version]

        #puts "in query: name_split: #{name_split.inspect}"
        self.class.gemlist(:justme => gem, :local => true, :gem_cmd => gem_cmd)
    end

    def uninstall
        name_split   = self.class.name_split(resource[:name])
        gem          = name_split[:gem]
        gem_cmd      = name_split[:gem_cmd]
        ruby_version = name_split[:ruby_version]

        execute("#{gem_cmd} uninstall -x -a #{gem}")
    end

    def update
        self.install(false)
    end

end

