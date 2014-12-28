require 'spec_helper'
require File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cuttlefish_smtp_server')

describe CuttlefishSmtpConnection do
  let(:connection) { CuttlefishSmtpConnection.new('') }
  let(:app) { App.create!(name: "test") }

  describe '#receive_message' do
    it 'can queue large messages' do
      # This data is still about double what should fit in a TEXT
      # Something six times bigger than this causes mysql to lose connection on OS X for Matthew
      connection.current.data = 'a' * 1000000
      connection.receive_message
    end
  end

  describe "#receive_plain_auth" do
    it { expect(connection.receive_plain_auth("foo", "bar")).to eq false }
    it { expect(connection.receive_plain_auth(app.smtp_username, "bar")).to eq false }
    it { expect(connection.receive_plain_auth(app.smtp_username, app.smtp_password)).to eq true }
  end

  describe "#get_server_greeting" do
    it { expect(connection.get_server_greeting).to eq "Cuttlefish SMTP server waves its arms and tentacles and says hello" }
  end
end
