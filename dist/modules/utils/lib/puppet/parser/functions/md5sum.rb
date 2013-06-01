#!/usr/bin/env ruby

require 'puppet'

module Puppet::Parser::Functions
  newfunction(:md5sum, :type => :rvalue) do |args|
    password = args[0]
    digest = Digest::MD5.hexdigest(password)
  end
end
