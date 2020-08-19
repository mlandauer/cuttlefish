# frozen_string_literal: true

require "spec_helper"

describe EmailServices::CreateFromData do
  let(:data_path) { "temp" }
  let(:to) { ["foo@foo.com"] }
  let(:data) { "Some email data" }
  let(:ignore_deny_list) { false }

  it "should create email, send email and clean up" do
    # Create a temporary file
    File.open(data_path, "w") do |f|
      f.write(data)
    end
    app = create(:app)
    expect(EmailServices::Send).to receive(:call)

    service = EmailServices::CreateFromData.call(
      to: to,
      data_path: data_path,
      app_id: app.id,
      ignore_deny_list: ignore_deny_list
    )
    email = service.result

    expect(email).to be_persisted
    expect(email.to).to eq to
    expect(email.data).to eq data
    expect(email.app).to eq app
    expect(email.ignore_deny_list).to eq ignore_deny_list

    expect(File.exist?(data_path)).to be false
  end
end
