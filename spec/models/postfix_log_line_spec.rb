require 'spec_helper'

describe PostfixLogLine do
  let(:line1) { "Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))" }
  let(:line2) { "Apr  5 18:41:58 kedumba postfix/qmgr[2638]: E69DB36D4A2B: removed" }
  let(:line3) { "Apr  5 17:11:07 kedumba postfix/smtpd[7453]: connect from unknown[111.142.251.143]" }
  let(:line4) { "Apr  5 14:21:51 kedumba postfix/smtp[2500]: 39D9336AFA81: to=<anincorrectemailaddress@openaustralia.org>, relay=aspmx.l.google.com[173.194.79.27]:25, delay=1, delays=0.08/0/0.58/0.34, dsn=5.1.1, status=bounced (host aspmx.l.google.com[173.194.79.27] said: 550-5.1.1 The email account that you tried to reach does not exist. zb4si15321910pbb.132 - gsmtp (in reply to RCPT TO command))" }
  let(:line5) { "Oct 25 17:36:47 vps331845 postfix[6084]: Postfix is running with backwards-compatible default setting" }

  context "one log line" do
    let (:l) do
      email = FactoryGirl.create(:email, to: "foo@bar.com")
      email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.first
    end

    describe ".relay" do
      it { expect(l.relay).to eq "foo.bar.com[1.2.3.4]:25" }
    end
    describe ".delay" do
      it { expect(l.delay).to eq "92780" }
    end
    describe ".delays" do
      it { expect(l.delays).to eq "92777/0.03/1.6/0.91" }
    end
    describe ".dsn" do
      it { expect(l.dsn).to eq "4.3.0" }
    end
    describe ".extended_status" do
      it { expect(l.extended_status).to eq "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))" }
    end
  end

  describe ".create_from_line" do
    it "should have an empty log lines on the delivery to start with" do
      email = FactoryGirl.create(:email, to: "foo@bar.com")
      email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
      expect(email.deliveries.first.postfix_log_lines).to be_empty
    end

    context "one log line" do
      let(:address) { Address.create!(text: "foo@bar.com")}
      let(:email) do
        email = FactoryGirl.create(:email, to_addresses: [address])
        email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
        email
      end
      let(:delivery) { Delivery.find_by(email: email, address: address) }

      before :each do
        email
        PostfixLogLine.create_from_line(line1)
      end

      it "should extract and save relevant parts of the line" do
        expect(PostfixLogLine.count).to eq 1
        line = delivery.postfix_log_lines.first
        expect(line.relay).to eq "foo.bar.com[1.2.3.4]:25"
        expect(line.delay).to eq "92780"
        expect(line.delays).to eq "92777/0.03/1.6/0.91"
        expect(line.dsn).to eq "4.3.0"
        expect(line.extended_status).to eq "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
        expect(line.time).to eq Time.local(Time.now.year,4,5,16,41,54)
      end

      it "should attach it to the delivery" do
        expect(email.deliveries.first.postfix_log_lines.count).to eq 1
        line = email.deliveries.first.postfix_log_lines.first
        expect(line.relay).to eq "foo.bar.com[1.2.3.4]:25"
        expect(line.delay).to eq "92780"
        expect(line.delays).to eq "92777/0.03/1.6/0.91"
        expect(line.dsn).to eq "4.3.0"
        expect(line.extended_status).to eq "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
        expect(line.time).to eq Time.local(Time.now.year,4,5,16,41,54)
      end
    end

    context "two log lines going to different destinations" do
      let(:address1) { Address.create!(text: "foo@bar.com") }
      let(:address2) { Address.create!(text: "anincorrectemailaddress@openaustralia.org") }
      let(:email) do
        email = FactoryGirl.create(:email, to_addresses: [address1, address2])
        email.deliveries.each {|d| d.update_attribute(:postfix_queue_id, "39D9336AFA81")}
        email
      end
      let(:delivery1) { Delivery.find_by(email: email, address: address1) }
      let(:delivery2) { Delivery.find_by(email: email, address: address2) }

      before :each do
        email
        PostfixLogLine.create_from_line(line1)
        PostfixLogLine.create_from_line(line4)
      end

      it "should attach it to the delivery" do
        expect(delivery1.postfix_log_lines.count).to eq 1
        expect(delivery2.postfix_log_lines.count).to eq 1
      end
    end

    it "should not reprocess duplicate lines" do
      address = Address.create!(text: "foo@bar.com")
      email = FactoryGirl.create(:email, to_addresses: [address])
      delivery = Delivery.find_by(email: email, address: address)
      delivery.update_attribute(:postfix_queue_id, "39D9336AFA81")

      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.create_from_line(line1)
      expect(delivery.postfix_log_lines.count).to eq 1
    end

    it "should recognise timeouts" do
      address = FactoryGirl.create(:address, text: "foobar@optusnet.com.au")
      delivery = FactoryGirl.create(:delivery, postfix_queue_id: "773A9CBBC", address: address)
      line = "Dec 21 07:41:10 localhost postfix/error[29539]: 773A9CBBC: to=<foobar@optusnet.com.au>, relay=none, delay=334, delays=304/31/0/0, dsn=4.4.1, status=deferred (delivery temporarily suspended: connect to extmail.optusnet.com.au[211.29.133.14]:25: Connection timed out)"
      PostfixLogLine.create_from_line(line)
      expect(PostfixLogLine.count).to eq 1
    end

    it "should not produce any log lines if the queue id is not recognised" do
      expect(PostfixLogLine).to receive(:puts).with("Skipping address foo@bar.com from postfix queue id 39D9336AFA81 - it's not recognised: Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))")
      PostfixLogLine.create_from_line(line1)
      expect(PostfixLogLine.count).to eq 0
    end

    it "should show a message if the address isn't recognised in a log line" do
      expect(PostfixLogLine).to receive(:puts).with("Skipping address foo@bar.com from postfix queue id 39D9336AFA81 - it's not recognised: Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))")
      email = FactoryGirl.create(:email)
      PostfixLogLine.create_from_line(line1)
    end

    it "should only log lines that are delivery attempts" do
      PostfixLogLine.create_from_line(line2)
      expect(PostfixLogLine.count).to eq 0
    end

    context "two emails with the same queue id" do
      let(:address) { Address.create!(text: "foo@bar.com") }
      let(:email1) do
        email = FactoryGirl.create(:email, to_addresses: [address], created_at: 10.minutes.ago)
        email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
        email
      end
      let(:email2) do
        email = FactoryGirl.create(:email, to_addresses: [address], created_at: 5.minutes.ago)
        email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
        email
      end
      let(:delivery1) { Delivery.find_by(email: email1, address: address) }
      let(:delivery2) { Delivery.find_by(email: email2, address: address) }

      it "should use the latest email" do
        delivery1
        delivery2
        PostfixLogLine.create_from_line(line1)
        expect(delivery1.postfix_log_lines).to be_empty
        expect(delivery2.postfix_log_lines.count).to eq 1
      end
    end

    it "should log and skip unrecognised lines" do
      expect(PostfixLogLine).to receive(:puts).with("Skipping unrecognised line: Oct 25 17:36:47 vps331845 postfix[6084]: Postfix is running with backwards-compatible default setting")
      email = FactoryGirl.create(:email)
      result = PostfixLogLine.create_from_line(line5)
      expect(result).to be_nil
    end
  end

  describe ".match_main_content" do
    it { expect(PostfixLogLine.match_main_content(line1)).to eq ({
      time: Time.local(Time.now.year,4,5,16,41,54),
      program: "smtp",
      queue_id: "39D9336AFA81",
      to: "foo@bar.com",
      relay: "foo.bar.com[1.2.3.4]:25",
      delay: "92780",
      delays: "92777/0.03/1.6/0.91",
      dsn: "4.3.0",
      extended_status: "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
    })}
    it { expect(PostfixLogLine.match_main_content(line2)).to eq ({
      time: Time.local(Time.now.year,4,5,18,41,58),
      program: "qmgr",
      queue_id: "E69DB36D4A2B",
    })}
    it { expect(PostfixLogLine.match_main_content(line3)).to eq ({
      time: Time.local(Time.now.year,4,5,17,11,7),
      program: "smtpd",
      queue_id: nil,
    })}
  end

  describe "#status" do
    it "should see a dsn of 2.0.0 as delivered" do
      expect(PostfixLogLine.new(dsn: "2.0.0").status).to eq "delivered"
    end

    it "should see a dsn of 5.1.1 as not delivered" do
      expect(PostfixLogLine.new(dsn: "5.1.1").status).to eq "hard_bounce"
    end

    it "should see a dsn of 4.4.1 as not delivered" do
      expect(PostfixLogLine.new(dsn: "4.4.1").status).to eq "soft_bounce"
    end

    # See https://github.com/mlandauer/cuttlefish/issues/49
    # 5.2.2 is mailbox full. It's a "permanent" failure that should be viewed
    # as a temporary one
    it "should see a dsn of 5.2.2 as a soft bounce" do
      expect(PostfixLogLine.new(dsn: "5.2.2").status).to eq "soft_bounce"
    end
  end
end
