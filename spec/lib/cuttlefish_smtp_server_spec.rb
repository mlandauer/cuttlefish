require 'spec_helper'
require File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cuttlefish_smtp_server')

describe CuttlefishSmtpConnection do
  describe '#receive_message' do
    it 'can queue large messages' do
      connection = CuttlefishSmtpConnection.new('')
      connection.current.data = 'foobar' * 1000000
      connection.receive_message
    end
  end
end
