# frozen_string_literal: true

describe AppServices::Update do
  let(:app) { create(:app, team: team) }
  let(:current_admin) { create(:admin, team: team) }
  let(:team) { create(:team) }
  let(:update_app) do
    described_class.call(
      current_admin: current_admin,
      id: app.id,
      attributes: attributes
    )
  end
  let(:attributes) do
    {
      name: name,
      open_tracking_enabled: app.open_tracking_enabled,
      click_tracking_enabled: app.click_tracking_enabled,
      custom_tracking_domain: app.custom_tracking_domain,
      from_domain: app.from_domain
    }
  end
  let(:name) { "An updated name" }

  it "updates the app name" do
    update_app
    app.reload
    expect(app.name).to eq name
  end

  it "is successfull" do
    expect(update_app).to be_success
  end

  it "returns the updated app" do
    expect(update_app.result.name).to eq name
  end

  context "with an invalid name" do
    let(:name) { "" }

    it "is not successfull" do
      expect(update_app).not_to be_success
    end

    it "returns the app" do
      expect(update_app.result.name).to eq name
    end
  end

  context "when the user doesn't have permission" do
    let(:app_policy) { double }

    before do
      expect(AppPolicy).to receive(:new) { app_policy }
      expect(app_policy).to receive(:update?).and_return(false)
    end

    it "is not successfull" do
      expect { update_app }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "when app doesn't exist" do
    before { app.destroy! }

    it "is not successfull" do
      expect { update_app }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when just updating from domain" do
    let(:attributes) { { from_domain: "foo.com" } }

    it "is successfull" do
      expect(update_app).to be_success
    end

    it "returns the updated app" do
      expect(update_app.result.from_domain).to eq "foo.com"
    end
  end

  context "when updating the custom tracking domain when the DNS for the domain is correctly setup" do
    let(:attributes) { { custom_tracking_domain: "foo.com" } }

    before do
      expect(App).to receive(:lookup_dns_cname_record).with("foo.com").and_return(App.cname_domain)
      app.update!(custom_tracking_domain_ssl_enabled: true)
    end

    it "is successfull" do
      expect(update_app).to be_success
    end

    it "returns the updated app" do
      expect(update_app.result.custom_tracking_domain).to eq "foo.com"
    end

    it "resets the custom_tracking_domain_ssl_enabled" do
      expect(update_app.result.custom_tracking_domain_ssl_enabled).to be false
    end
  end
end
