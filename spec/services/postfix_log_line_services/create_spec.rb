# frozen_string_literal: true

require "spec_helper"
require "sidekiq/testing"

describe PostfixLogLineServices::Create do
  context "soft bounce" do
    let(:line) do
      "Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: " \
        "to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, " \
        "delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred " \
        "(host foo.bar.com[1.2.3.4] said: 451 4.3.0 " \
        "<bounces@planningalerts.org.au>: Temporary lookup failure " \
        "(in reply to RCPT TO command))"
    end
    let(:address) { create(:address, text: "foo@bar.com") }
    let(:app) do
      app = create(:app, webhook_key: "abc123")
      # We don't want validations to get called here
      app.update_column(:webhook_url, "https://foo.com")
      app
    end
    let(:email) { create(:email, app: app) }
    let!(:delivery) { create(:delivery, email: email, postfix_queue_id: "39D9336AFA81", address: address) }

    it "creates a postfix log line record" do
      PostfixLogLineServices::Create.call(line)

      expect(PostfixLogLine.count).to eq 1
      p = PostfixLogLine.first
      expect(p.time).to eq Time.new(Time.now.year, 4, 5, 16, 41, 54)
      expect(p.dsn).to eq "4.3.0"
      expect(p.extended_status).to eq(
        "deferred (host foo.bar.com[1.2.3.4] said: " \
        "451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
      )
      expect(p.delivery).to eq delivery
    end

    it "does not add anything to the deny list" do
      PostfixLogLineServices::Create.call(line)

      expect(DenyList.count).to be_zero
    end

    it "posts to the webhook" do
      Sidekiq::Testing.inline! do
        expect(WebhookServices::PostDeliveryEvent).to receive(:call)
        PostfixLogLineServices::Create.call(line)
      end
    end
  end

  context "hard bounce" do
    let(:line) do
      "Apr  5 14:21:51 kedumba postfix/smtp[2500]: 39D9336AFA81: " \
        "to=<anincorrectemailaddress@openaustralia.org>, " \
        "relay=aspmx.l.google.com[173.194.79.27]:25, delay=1, " \
        "delays=0.08/0/0.58/0.34, dsn=5.1.1, status=bounced " \
        "(host aspmx.l.google.com[173.194.79.27] said: 550-5.1.1 " \
        "The email account that you tried to reach does not exist. " \
        "zb4si15321910pbb.132 - gsmtp (in reply to RCPT TO command))"
    end
    let(:address) { create(:address, text: "anincorrectemailaddress@openaustralia.org") }
    let!(:delivery) { create(:delivery, postfix_queue_id: "39D9336AFA81", address: address) }

    it "creates a postfix log line record" do
      PostfixLogLineServices::Create.call(line)

      expect(PostfixLogLine.count).to eq 1
      p = PostfixLogLine.first
      expect(p.time).to eq Time.new(Time.now.year, 4, 5, 14, 21, 51)
      expect(p.dsn).to eq "5.1.1"
      expect(p.extended_status).to eq(
        "bounced (host aspmx.l.google.com[173.194.79.27] said: " \
        "550-5.1.1 The email account that you tried to reach does not exist. " \
        "zb4si15321910pbb.132 - gsmtp (in reply to RCPT TO command))"
      )
      expect(p.delivery).to eq delivery
    end

    it "adds the address to the deny list" do
      PostfixLogLineServices::Create.call(line)

      expect(DenyList.count).to eq 1
      d = DenyList.first
      expect(d.address).to eq address
      expect(d.caused_by_postfix_log_line.delivery).to eq delivery
      expect(d.app).to eq delivery.app
    end

    it "does not post the webhook because the url isn't set" do
      Sidekiq::Testing.inline! do
        expect(WebhookServices::PostDeliveryEvent).to_not receive(:call)
        PostfixLogLineServices::Create.call(line)
      end
    end

    context "address is already on the deny list" do
      before { create(:deny_list, address: address, app: delivery.app) }

      it "does not create another deny list" do
        expect(DenyList.count).to eq 1
      end
    end
  end

  context "hard bounce for a cuttlefish email" do
    let(:line) do
      "Apr  5 14:21:51 kedumba postfix/smtp[2500]: 39D9336AFA81: " \
        "to=<anincorrectemailaddress@openaustralia.org>, " \
        "relay=aspmx.l.google.com[173.194.79.27]:25, delay=1, " \
        "delays=0.08/0/0.58/0.34, dsn=5.1.1, status=bounced " \
        "(host aspmx.l.google.com[173.194.79.27] said: 550-5.1.1 " \
        "The email account that you tried to reach does not exist. " \
        "zb4si15321910pbb.132 - gsmtp (in reply to RCPT TO command))"
    end
    let(:address) { create(:address, text: "anincorrectemailaddress@openaustralia.org") }
    let(:email) { create(:email, app: App.cuttlefish) }
    let!(:delivery) { create(:delivery, email: email, postfix_queue_id: "39D9336AFA81", address: address) }

    it "creates a postfix log line record" do
      PostfixLogLineServices::Create.call(line)

      expect(PostfixLogLine.count).to eq 1
    end

    it "adds the address to the cuttlefish app deny list" do
      PostfixLogLineServices::Create.call(line)

      expect(DenyList.count).to eq 1
      expect(DenyList.first.app).to eq App.cuttlefish
    end
  end
end
