#!/usr/bin/env ruby
# If you need a bit of debugging output in the threads add -d to the line above

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "cuttlefish_control"))

CuttlefishControl.smtp_start
