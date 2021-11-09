# frozen_string_literal: true

require "spec_helper"

describe AppServices::Create do
  let(:current_admin) { create(:admin) }
  let(:name) { "An app" }
  let(:create_app) do
    AppServices::Create.call(
      current_admin: current_admin,
      name: name,
      open_tracking_enabled: false,
      click_tracking_enabled: false,
      custom_tracking_domain: nil,
      from_domain: nil,
      dkim_enabled: false,
      webhook_url: nil
    )
  end

  it "creates an app" do
    expect { create_app }.to change { App.count }.by(1)
  end

  it "returns the created app" do
    app = create_app.result
    expect(app.name).to eq "An app"
    expect(app.open_tracking_enabled).to eq false
    expect(app.click_tracking_enabled).to eq false
    expect(app.custom_tracking_domain).to be_nil
  end

  it "creates the app in the same team as the admin" do
    expect(create_app.result.team).to eq current_admin.team
  end

  it "is successfull" do
    expect(create_app).to be_success
  end

  context "name is blank" do
    let(:name) { "" }
    it "is not succesfull" do
      expect(create_app).to_not be_success
    end

    it "returns the unsaved app" do
      expect(create_app.result).to_not be_persisted
    end
  end

  context "user does not have permission" do
    let(:app_policy) { double }
    before :each do
      expect(AppPolicy).to receive(:new) { app_policy }
      expect(app_policy).to receive(:create?) { false }
    end

    it "is not successfull" do
      expect { create_app }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
