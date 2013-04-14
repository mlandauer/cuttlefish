require 'spec_helper'

describe PostfixLogLine do
  let(:line1) { "Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))" }
  let(:line2) { "Apr  5 18:41:58 kedumba postfix/qmgr[2638]: E69DB36D4A2B: removed" }
  let(:line3) { "Apr  5 17:11:07 kedumba postfix/smtpd[7453]: connect from unknown[111.142.251.143]" }
  let(:line4) { "Apr  5 14:21:51 kedumba postfix/smtp[2500]: 39D9336AFA81: to=<anincorrectemailaddress@openaustralia.org>, relay=aspmx.l.google.com[173.194.79.27]:25, delay=1, delays=0.08/0/0.58/0.34, dsn=5.1.1, status=bounced (host aspmx.l.google.com[173.194.79.27] said: 550-5.1.1 The email account that you tried to reach does not exist. zb4si15321910pbb.132 - gsmtp (in reply to RCPT TO command))" }

  context "one log line" do
    let (:l) do
      email = Email.create!(to: "foo@bar.com")
      email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.first
    end

    describe ".relay" do
      it { l.relay.should == "foo.bar.com[1.2.3.4]:25" }
    end
    describe ".delay" do
      it { l.delay.should == "92780" }
    end
    describe ".delays" do
      it { l.delays.should == "92777/0.03/1.6/0.91" }
    end
    describe ".dsn" do
      it { l.dsn.should == "4.3.0" }
    end
    describe ".extended_status" do
      it { l.extended_status.should == "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))" }
    end
  end

  describe ".create_from_line" do
    it "should have an empty log lines on the delivery to start with" do
      email = Email.create!(to: "foo@bar.com")
      email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
      email.deliveries.first.postfix_log_lines.should be_empty
    end

    context "one log line" do
      let(:address) { Address.create!(text: "foo@bar.com")}
      let(:email) do
        email = Email.create!(to_addresses: [address])
        email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
        email
      end
      let(:delivery) { Delivery.find_by(email: email, address: address) }

      before :each do
        email
        PostfixLogLine.create_from_line(line1)
      end

      it "should extract and save relevant parts of the line" do
        PostfixLogLine.count.should == 1
        line = delivery.postfix_log_lines.first
        line.relay.should == "foo.bar.com[1.2.3.4]:25"
        line.delay.should == "92780"
        line.delays.should == "92777/0.03/1.6/0.91"
        line.dsn.should == "4.3.0"
        line.extended_status.should == "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
        line.time.should == Time.local(2013,4,5,16,41,54)
      end

      it "should attach it to the delivery" do
        email.deliveries.first.postfix_log_lines.count.should == 1
        line = email.deliveries.first.postfix_log_lines.first
        line.relay.should == "foo.bar.com[1.2.3.4]:25"
        line.delay.should == "92780"
        line.delays.should == "92777/0.03/1.6/0.91"
        line.dsn.should == "4.3.0"
        line.extended_status.should == "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
        line.time.should == Time.local(2013,4,5,16,41,54)
      end
    end

    context "two log lines going to different destinations" do
      let(:address1) { Address.create!(text: "foo@bar.com") }
      let(:address2) { Address.create!(text: "anincorrectemailaddress@openaustralia.org") }
      let(:email) do
        email = Email.create!(:to_addresses => [address1, address2])
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
        delivery1.postfix_log_lines.count.should == 1
        delivery2.postfix_log_lines.count.should == 1
      end
    end

    it "should not reprocess duplicate lines" do
      address = Address.create!(text: "foo@bar.com")
      email = Email.create!(to_addresses: [address])
      delivery = Delivery.find_by(email: email, address: address)
      delivery.update_attribute(:postfix_queue_id, "39D9336AFA81")

      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.create_from_line(line1)
      delivery.postfix_log_lines.count.should == 1
    end

    it "should not produce any log lines if the queue id is not recognised" do
      PostfixLogLine.should_receive(:puts).with("Skipping address foo@bar.com from postfix queue id 39D9336AFA81 - it's not recognised")
      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.count.should == 0
    end

    it "should show a message if the address isn't recognised in a log line" do
      PostfixLogLine.should_receive(:puts).with("Skipping address foo@bar.com from postfix queue id 39D9336AFA81 - it's not recognised")
      email = Email.create!
      PostfixLogLine.create_from_line(line1)      
    end

    it "should only log lines that are delivery attempts" do
      PostfixLogLine.create_from_line(line2)
      PostfixLogLine.count.should == 0
    end

    context "two emails with the same queue id" do
      let(:address) { Address.create!(text: "foo@bar.com") }
      let(:email1) do
        email = Email.create!(:to_addresses => [address], :created_at => 10.minutes.ago)
        email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
        email
      end
      let(:email2) do
        email = Email.create!(:to_addresses => [address], :created_at => 5.minutes.ago)
        email.deliveries.first.update_attribute(:postfix_queue_id, "39D9336AFA81")
        email
      end
      let(:delivery1) { Delivery.find_by(email: email1, address: address) }
      let(:delivery2) { Delivery.find_by(email: email2, address: address) }

      it "should use the latest email" do
        delivery1
        delivery2
        PostfixLogLine.create_from_line(line1)      
        delivery1.postfix_log_lines.should be_empty
        delivery2.postfix_log_lines.count.should == 1
      end
    end
  end

  describe ".match_main_content" do
    it { PostfixLogLine.match_main_content(line1).should == {
      time: Time.local(2013,4,5,16,41,54),
      program: "smtp",
      pid: "18733",
      queue_id: "39D9336AFA81",
      program_content: "to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))",
      to: "foo@bar.com",
      relay: "foo.bar.com[1.2.3.4]:25",
      delay: "92780",
      delays: "92777/0.03/1.6/0.91",
      dsn: "4.3.0",
      status: "deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
    }}
    it { PostfixLogLine.match_main_content(line2).should == {
      time: Time.local(2013,4,5,18,41,58),
      program: "qmgr",
      pid: "2638",
      queue_id: "E69DB36D4A2B",
      program_content: "removed"
    }}
    it { PostfixLogLine.match_main_content(line3).should == {
      time: Time.local(2013,4,5,17,11,7),
      program: "smtpd",
      pid: "7453",
      queue_id: nil,
      program_content: "connect from unknown[111.142.251.143]"
    }}
  end

  describe "#status" do
    it "should see a dsn of 2.0.0 as delivered" do
      PostfixLogLine.new(:dsn => "2.0.0").status.should == "delivered"
    end

    it "should see a dsn of 5.1.1 as not delivered" do
      PostfixLogLine.new(:dsn => "5.1.1").status.should == "hard_bounce"
    end

    it "should see a dsn of 4.4.1 as not delivered" do
      PostfixLogLine.new(:dsn => "4.4.1").status.should == "soft_bounce"
    end
  end
end
