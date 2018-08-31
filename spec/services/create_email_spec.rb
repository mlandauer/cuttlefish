require 'spec_helper'

describe CreateEmail do
  # let(:app) { team.apps.create!(name: "Test") }
  let(:app) { create(:app) }

  it "should send a test email" do
    expect(MailWorker).to receive(:perform_async)
    CreateEmail.call(
      from: "contact@cuttlefish.io",
      to: "matthew@openaustralia.org",
      cc: nil,
      subject: "Test",
      text_part: "Hello. How are you?",
      html_part: "<p>Hello. How are you?</p>",
      app_id: app.id
    )
  end

  it "should create an email" do
    expect {
      CreateEmail.call(
        from: "contact@cuttlefish.io",
        to: "matthew@openaustralia.org",
        cc: nil,
        subject: "Test",
        text_part: "Hello. How are you?",
        html_part: "<p>Hello. How are you?</p>",
        app_id: app.id
      )
    }.to change { Email.count }.by(1)
  end
end
