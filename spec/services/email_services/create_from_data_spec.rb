# frozen_string_literal: true

require "spec_helper"

describe EmailServices::CreateFromData do
  let(:data_path) { "temp" }
  let(:to) { ["foo@foo.com"] }
  let(:data) { "Some email data" }
  let(:ignore_deny_list) { false }
  let(:app) { create(:app) }
  let(:service) do
    EmailServices::CreateFromData.new(
      to: to,
      data_path: data_path,
      app_id: app.id,
      ignore_deny_list: ignore_deny_list
    )
  end

  before(:each) do
    # Create a temporary file
    File.open(data_path, "w") do |f|
      f.write(data)
    end
  end

  after(:each) do
    File.delete(data_path) if File.exist?(data_path)
  end

  it "#create" do
    email = service.create
    expect(email).to be_persisted
    expect(email.to).to eq to
    expect(email.data).to eq data
    expect(email.app).to eq app
    expect(email.ignore_deny_list).to eq ignore_deny_list
  end

  it "#send" do
    email = create(:email)
    expect(EmailServices::Send).to receive(:call).with(email: email)
    service.send(email)
  end

  it "#cleanup" do
    service.cleanup
    expect(File.exist?(data_path)).to be false
  end
end
