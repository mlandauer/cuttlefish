# frozen_string_literal: true

require "spec_helper"

describe App do
  describe "#smtp_password" do
    it "creates a password that is twenty characters long" do
      expect(create(:app).smtp_password.size).to eq 20
    end

    it "creates a password that is different every time" do
      expect(create(:app).smtp_password).not_to eq(
        create(:app).smtp_password
      )
    end
  end

  describe "#name" do
    it "allows letters, numbers, spaces and underscores" do
      expect(build(:app, name: "Foo12 Bar_Foo")).to be_valid
    end

    it "does not allow other characters" do
      expect(build(:app, name: "*")).not_to be_valid
    end
  end

  describe "#smtp_username" do
    it "sets the smtp_username based on the name when created" do
      app = create(:app, name: "Planning Alerts", id: 15)
      expect(app.smtp_username).to eq "planning_alerts_15"
    end

    it "does not change the smtp_username if the name is updated" do
      app = create(:app, name: "Planning Alerts", id: 15)
      app.update_attributes(name: "Another description")
      expect(app.smtp_username).to eq "planning_alerts_15"
    end
  end

  describe "#custom_tracking_domain" do
    it "looks up the cname of the custom domain and check it points to the cuttlefish server" do
      app = build(:app, custom_tracking_domain: "email.myapp.com")
      expect(App).to receive(:lookup_dns_cname_record)
        .with("email.myapp.com").and_return("localhost.")
      expect(app).to be_valid
    end

    it "looks up the cname of the custom domain and check it points to the cuttlefish server" do
      app = build(:app, custom_tracking_domain: "email.foo.com")
      expect(App).to receive(:lookup_dns_cname_record)
        .with("email.foo.com").and_return("foo.com.")
      expect(app).not_to be_valid
    end

    it "does not look up the cname if the custom domain hasn't been set" do
      app = build(:app)
      expect(App).not_to receive(:lookup_dns_cname_record)
      expect(app).to be_valid
    end
  end

  describe "dkim validation" do
    let(:app) { create(:app, id: 12) }

    context "dkim disabled" do
      before { app.dkim_enabled = false }

      context "a from domain specified" do
        before { app.from_domain = "foo.com" }

        it "is valid" do
          expect(app).to be_valid
        end
      end
    end

    context "dkim enabled" do
      before { app.dkim_enabled = true }

      context "no from domain specified" do
        it "is not valid" do
          expect(app).not_to be_valid
        end

        it "has a sensible error message" do
          app.valid?
          expect(app.errors.messages).to eq(
            dkim_enabled: ["can't be enabled if from_domain is not set"]
          )
        end
      end

      context "a from domain specified" do
        before { app.from_domain = "foo.com" }

        context "that has dns setup" do
          before do
            allow_any_instance_of(DkimDns).to receive(:dkim_dns_configured?).and_return(true)
          end

          it "is valid" do
            expect(app).to be_valid
          end
        end

        context "that has no dns setup" do
          before do
            allow_any_instance_of(DkimDns).to receive(:dkim_dns_configured?).and_return(false)
          end

          it "is not valid" do
            expect(app).not_to be_valid
          end

          it "has an error message" do
            app.valid?
            expect(app.errors.messages).to eq(
              from_domain: [
                "doesn't have a DNS record configured correctly for " \
                "my_app_12.cuttlefish._domainkey.foo.com"
              ]
            )
          end
        end
      end
    end
  end

  describe "#tracking_domain_info" do
    let(:custom_tracking_domain) { nil }
    let(:app) { build(:app, custom_tracking_domain: custom_tracking_domain) }

    it "by default returns the cuttlefish domain and use https" do
      expect(app.tracking_domain_info).to eq(
        protocol: "https",
        domain: Rails.configuration.cuttlefish_domain
      )
    end

    context "with a custom tracking domain" do
      let(:custom_tracking_domain) { "foo.com" }

      it "returns the custom tracking domain and use http" do
        expect(app.tracking_domain_info).to eq(
          protocol: "http",
          domain: "foo.com"
        )
      end
    end

    context "in development environment" do
      before do
        allow(Rails).to receive_message_chain(:env, :development?) { true }
      end

      it "returns the localhost and use http" do
        expect(app.tracking_domain_info).to eq(
          protocol: "http",
          domain: "localhost:3000"
        )
      end
    end
  end

  describe "#dkim_private_key" do
    it "is generated automatically" do
      app = create(:app)
      expect(app.dkim_private_key.to_pem.split("\n").first).to eq(
        "-----BEGIN RSA PRIVATE KEY-----"
      )
    end

    it "is different for different apps" do
      app1 = create(:app)
      app2 = create(:app)
      expect(app1.dkim_private_key).not_to eq app2.dkim_private_key
    end

    it "is saved in the database" do
      app = create(:app)
      value = app.dkim_private_key.to_pem
      app.reload
      expect(app.dkim_private_key.to_pem).to eq value
    end
  end

  describe "#dkim_selector" do
    let(:app) { create(:app, name: "Book store", id: 15) }

    it "includes the name and the id to be unique" do
      expect(app.dkim_selector).to eq "book_store_15.cuttlefish"
    end

    context "legacy dkim selector" do
      let(:app) { create(:app, legacy_dkim_selector: true) }

      it "justs be cuttlefish" do
        expect(app.dkim_selector).to eq "cuttlefish"
      end
    end
  end

  describe ".cuttlefish" do
    before do
      allow(Rails.configuration).to receive(:cuttlefish_domain)
        .and_return("cuttlefish.io")
    end

    let(:app) { App.cuttlefish }

    it { expect(app.name).to eq "Cuttlefish" }
    it { expect(app.from_domain).to eq "cuttlefish.io" }
    it { expect(app.team).to be_nil }

    it "returns the same instance when request twice" do
      expect(app.id).to eq App.cuttlefish.id
    end
  end

  describe "#open_tracking_enabled" do
    it "does not validate with nil value" do
      app = build(:app, open_tracking_enabled: nil)
      expect(app).not_to be_valid
    end
  end

  # The following two tests are commented out because they require a network
  # connection and are testing real things in DNS so in general it makes the
  # tests fragile. Though, if you're working on the lookup_dns_cname_record
  # method it's probably a good idea to uncomment them!

  # describe "#lookup_dns_cname_record" do
  #   it "should resolve the cname of www.openaustralia.org" do
  #     expect(App.lookup_dns_cname_record("www.openaustralia.org")).to eq(
  #       "kedumba.openaustralia.org."
  #     )
  #   end
  #
  #   it "should not resolve the cname of twiddlesticks.openaustralia.org" do
  #     expect(
  #       App.lookup_dns_cname_record("twiddlesticks.openaustralia.org")
  #     ).to be_nil
  #   end
  # end

  describe "#webhook_url" do
    it "validates if the url returns 200 code from POST" do
      url = "https://www.planningalerts.org.au/deliveries"
      key = "abc123"
      expect(WebhookServices::PostTestEvent).to receive(:call).with(
        url: url, key: key
      )
      app = build(:app, webhook_url: url, webhook_key: key)
      expect(app).to be_valid
    end

    it "validates with nil and not try to do a POST" do
      expect(WebhookServices::PostTestEvent).not_to receive(:call)
      app = build(:app, webhook_url: nil)
      expect(app).to be_valid
    end

    it "does not validate if the url returns a 404" do
      VCR.use_cassette("webhook") do
        app = build(
          :app,
          webhook_url: "https://www.planningalerts.org.au/deliveries"
        )
        expect(app).not_to be_valid
        expect(app.errors[:webhook_url]).to eq(
          ["returned 404 code when doing POST to https://www.planningalerts.org.au/deliveries"]
        )
      end
    end

    it "does not validate if the webhook can't connect" do
      expect(WebhookServices::PostTestEvent).to receive(:call).and_raise(
        SocketError.new("Failed to open TCP connection to foo:80 (getaddrinfo: Name or service not known)")
      )
      app = build(
        :app,
        webhook_url: "foo"
      )
      expect(app).not_to be_valid
      expect(app.errors[:webhook_url]).to eq(
        ["error when doing test POST to foo: " \
         "Failed to open TCP connection to foo:80 (getaddrinfo: Name or service not known)"]
      )
    end
  end
end
