require 'spec_helper'
require File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cuttlefish_smtp_server')

describe CuttlefishSmtpConnection do
  describe '#receive_message' do
    it 'can queue large messages' do
      connection = CuttlefishSmtpConnection.new('')
      # This data is still about double what should fit in a TEXT
      # Something six times bigger than this causes mysql to lose connection on OS X for Matthew
      connection.current.data = 'a' * 1000000
      connection.receive_message
    end
  end
end
