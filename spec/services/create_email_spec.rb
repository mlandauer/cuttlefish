require 'spec_helper'

describe CreateEmail do
  # let(:app) { team.apps.create!(name: "Test") }
  let(:app) { create(:app) }
  let(:create_email) {
    CreateEmail.call(
      from: "contact@cuttlefish.io",
      to: "matthew@openaustralia.org",
      cc: nil,
      subject: "Test",
      text_part: "Hello. How are you?",
      html_part: "<p>Hello. How are you?</p>",
      app_id: app.id
    )
  }

  it "should send a test email" do
    expect(MailWorker).to receive(:perform_async)
    create_email
  end

  it "should create an email" do
    expect { create_email }.to change { Email.count }.by(1)
  end

  it "should return an email" do
    expect(create_email).to be_an(Email)
  end
end
