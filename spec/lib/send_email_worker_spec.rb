# frozen_string_literal: true

require "spec_helper"
require "ostruct"

describe SendEmailWorker, "#perform" do
  let(:email) { create(:email) }

  it "should forward the email information" do
    expect(EmailServices::Send).to receive(:call)

    SendEmailWorker.new.perform(email.id)
  end
end
