describe UpdateApp do
  let(:app) { create(:app, team: team) }
  let(:current_admin) { create(:admin, team: team) }
  let(:team) { create(:team) }
  let(:update_app) {
    UpdateApp.call(
      current_admin: current_admin,
      id: app.id,
      name: "An updated name",
      open_tracking_enabled: app.open_tracking_enabled,
      click_tracking_enabled: app.click_tracking_enabled,
      custom_tracking_domain: app.custom_tracking_domain,
      from_domain: app.from_domain
    )
  }

  it "should update the app name" do
    app
    update_app
    app.reload
    expect(app.name).to eq "An updated name"
  end
end
