=begin

uaA ruby interface to http://user-agent-string.info/
A ruby version of http://user-agent-string.info/download/UASparser

By Vladimir Slaykovsky
email: vslaykovsky AT gmail DOT com

Usage:

require 'uasparser'

uas_parser = UASparser.new('/path/to/your/cache/folder')

result = uas_parser.parse('YOUR_USERAGENT_STRING',entire_url='ua_icon,os_icon') #only 'ua_icon' or 'os_icon' or both are allowed in entire_url


Examples:

require 'uasparser'
uas = UASparser.new
test = ['SonyEricssonK750i/R1L Browser/SEMC-Browser/4.2 Profile/MIDP-2.0 Configuration/CLDC-1.1',
        'Mozilla/5.0 (Windows; U; Windows NT 5.2; en-GB; rv:1.8.1.18) Gecko/20081029 Firefox/2.0.0.18',
        'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_5; en-us) AppleWebKit/525.26.2 (KHTML, like Gecko) Version/3.2 Safari/525.26.12',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows XP 5.1) Lobo/0.98.4',
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; )',
        'Opera/9.80 (Windows NT 5.1; U; cs) Presto/2.2.15 Version/10.00',
        'boxee (alpha/Darwin 8.7.1 i386 - 0.9.11.5591)',
        'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; CSM-NEWUSER; GTB6; byond_4.0; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 1.1.4322; .NET CLR 3.0.04506.648; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; InfoPath.1)',
        'Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)',
        ]

for item in test
    res = uas.parse(item)
    puts "---#{res['typ']}: #{res['ua_name']} @ #{res['os_name']}"
end

=end


class UASparser

  require 'net/http'
  require 'uri'

  def initialize(cache_dir=nil)
    @ini_url  = 'http://user-agent-string.info/rpc/get_data.php?key=free&format=ini'
    @ver_url  = 'http://user-agent-string.info/rpc/get_data.php?key=free&format=ini&ver=y'
    @info_url = 'http://user-agent-string.info'
    @os_img_url = 'http://user-agent-string.info/pub/img/os/%s'
    @ua_img_url = 'http://user-agent-string.info/pub/img/ua/%s'

    @cache_file_name = 'cache'
    @cache_data = nil
    @update_interval = 3600*24*10 # 10 days
    @cache_dir = (cache_dir or File.dirname(__FILE__))
    if not File.writable? @cache_dir
      throw "Cache directory %s is not writable."
    end
    @cache_file_name = File.join(@cache_dir, @cache_file_name)
  end

  def toRubyReg(reg)
    reg_l = reg[1..(reg.rindex('/')-1)] # modify the re into ruby format
    reg_r = reg[reg.rindex('/')+1..-1]
    flag = 0
    flag = (flag | Regexp::MULTILINE) if reg_r.index 's'
    flag = (flag | Regexp::IGNORECASE) if reg_r.index 'i'
    return Regexp.new(reg_l, flag)
  end

  def parse(useragent, entire_url='')
    ret = {'typ'=>'unknown',
           'ua_family'=>'unknown',
           'ua_name'=>'unknown',
           'ua_url'=>'unknown',
           'ua_company'=>'unknown',
           'ua_company_url'=>'unknown',
           'ua_icon'=>'unknown.png',
           'ua_info_url'=>'unknown',
           'os_family'=>'unknown',
           'os_name'=>'unknown',
           'os_url'=>'unknown',
           'os_company'=>'unknown',
           'os_company_url'=>'unknown',
           'os_icon'=>'unknown.png'}

    os_index = ['os_family', 'os_name', 'os_url', 'os_company', 'os_company_url', 'os_icon']
    ua_index = ['ua_family', 'ua_name', 'ua_url', 'ua_company', 'ua_company_url', 'ua_icon', '', 'ua_info_url']

    ret['ua_icon'] = @ua_img_url % ret['ua_icon'] if entire_url.index 'ua_icon'
    ret['os_icon'] = @os_img_url % ret['os_icon'] if entire_url.index 'os_icon'


    #Check argument
    throw "Excepted argument useragent is not given." if not useragent


    #Load cache data
    data = loadData()

    #Is it a spider?
    for index in data['robots']['order']
      test = data['robots'][index]
      if test[0] == useragent
        ret['typ'] = 'Robot'
        for i in 1..(test.length+1)
          if i < 6
            ret[ua_index[i-1]] = test[i]
          elsif i==6
            ret[ua_index[i-1]] = (entire_url.index('ua_icon') and @ua_img_url or test[i])
          elsif i==7
            if not test[7].nil? and not test[7].length == 0
              for j in 1..(data['os'][Integer(test[7])]..length)
                ret[os_index[j]] = data['os'][Integer(test[7])][j]
              end
            end
          elsif i==8
            ret[ua_index[i-1]] = [@info_url, test[i]].join('')
          end
        end
        return ret
      end
    end

    #A browser
    id_browser = nil
    for index in data['browser_reg']['order']
      test = data['browser_reg'][index]
      test_rg = toRubyReg(test[0]).match(useragent) #All regular expression should be in ruby format
      if test_rg
        id_browser = Integer(test[1]) #Bingo
        info = test_rg[1]
        break
      end
    end

    # Get broser detail
    if id_browser
      _index = ['ua_family', 'ua_url', 'ua_company', 'ua_company_url', 'ua_icon', 'ua_info_url']
      begin
        if data['browser'].has_key?(id_browser)
          for i in 1..(data['browser'][id_browser].length+1)
            if i <= 4
              ret[_index[i-1]] = data['browser'][id_browser][i]
            elsif i == 5
              ret[_index[i-1]] = (entire_url.index('ua_icon') and @ua_img_url or data['browser'][id_browser][i].to_s)
            else
              ret[_index[i-1]] = [@info_url, data['browser'][id_browser][i]].join ""
            end
          end
        end
      rescue
      end
      begin
        ret['typ'] = data['browser_type'][Integer(data['browser'][id_browser][0])][0]
        ret['ua_name'] = "#{data['browser'][id_browser][1]} #{info}"
      rescue
      end
    end

    # Get OS detail
    if data['browser_os'].has_key? id_browser
      begin
        os_id = Integer(data['browser_os'][id_browser][0])
        for i in 0..data['os'][os_id].length
          if i<5
            ret[os_index[i]] = data['os'][os_id][i]
          else
            ret[os_index[i]] = (entire_url.index('os_icon') and @os_img_url or data['os'][os_id][i].to_s)
          end
          return ret
        end
      rescue
      end
    end

    #Try to match an OS
    os_id = nil
    for index in data['os_reg']['order']
      test = data['os_reg'][index]
      test_rg = toRubyReg(test[0]).match(useragent)
      if test_rg
        os_id = Integer(test[1])
        break
      end
    end
    # Get OS detail
    if os_id and data['os'].has_key?(os_id)
      for i in 0..data['os'][os_id].length
        if i<5
          ret[os_index[i]] = data['os'][os_id][i]
        else
          ret[os_index[i]] = (entire_url.index('os_icon') and @os_img_url or data['os'][os_id][i].to_s)
        end
      end
    end
    return ret
  end

  def _parseIniFile(file)
    data = {}
    current_section = 'unknown'
    section_pat = Regexp.new(/^\[(\S+)\]$/)
    option_pat = Regexp.new(/^(\d+)\[\]\s=\s"(.*)"$/)

    for line in file.split("\n")
      option = option_pat.match(line)
      if option
        key = Integer(option[1])
        if data[current_section].has_key?(key)
          data[current_section][key].push(option[2])
        else
          data[current_section][key] = [option[2]]
          data[current_section]['order'].push(key)
        end
      else
        section = section_pat.match(line) #do something for section
        if section
          current_section = section[1]
          data[current_section] = {'order'=>[]}
        end
      end
    end
    return data
  end

  def _fetchURL(url)
    Net::HTTP.get_response(URI.parse(url)).body
  end

  def _checkCache()
    cache_file = @cache_file_name
    if not File.exist?(cache_file)
      return false
    else
      mtime = File.mtime(cache_file)
      if mtime < Time.now() - @update_interval
        return false
      end
    end
    return true
  end

  def updateData()
    ver_data = nil
    begin
      ver_data = _fetchURL(@ver_url)
      if File.exist?(@cache_file_name)
        cache_file = File.new(@cache_file_name, 'rb')
        data = Marshal.load(cache_file)
        if data['version'] == ver_data
          return true
        end
      end
    rescue
      throw "Failed to get version of lastest data"
    end

    begin
      cache_file = File.new(@cache_file_name, 'wb')
      ini_file = _fetchURL(@ini_url)
      ini_data = _parseIniFile(ini_file)
      if ver_data
        ini_data['version'] = ver_data
      end
    rescue
      throw ("Failed to download cache data")
    end

    Marshal.dump(ini_data, cache_file)
    cache_file.close
    return true
  end

  def loadData()
    if not _checkCache()
      updateData()
    else
      if @cache_data #no need to load
        return @cache_data
      end
    end

    @cache_data = Marshal.load(open(@cache_file_name, 'rb'))

    return @cache_data
  end
end

#simple test
#uas = UASparser.new
#puts uas.parse('SonyEricssonK750i/R1L Browser/SEMC-Browser/4.2 Profile/MIDP-2.0 Configuration/CLDC-1.1', 'os_icon')
#puts uas.parse('Yandex/1.01.001 (compatible; Win16; I)', 'os_icon')
