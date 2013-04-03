#!/usr/bin/env ruby
# If you need a bit of debugging output in the threads add -d to the line above

$: << File.join(File.dirname(__FILE__), "..", "lib")

require 'cuttlefish_control'

CuttlefishControl.smtp_start
