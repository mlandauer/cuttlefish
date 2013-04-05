require 'spec_helper'

describe PostfixLogLine do
  let(:line1) { "Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))" }
  let(:line2) { "Apr  5 18:41:58 kedumba postfix/qmgr[2638]: E69DB36D4A2B: removed" }
  let(:line3) { "Apr  5 17:11:07 kedumba postfix/smtpd[7453]: connect from unknown[111.142.251.143]" }
  let(:line4) { "Apr  5 14:21:51 kedumba postfix/smtp[2500]: 39D9336AFA81: to=<anincorrectemailaddress@openaustralia.org>, relay=aspmx.l.google.com[173.194.79.27]:25, delay=1, delays=0.08/0/0.58/0.34, dsn=5.1.1, status=bounced (host aspmx.l.google.com[173.194.79.27] said: 550-5.1.1 The email account that you tried to reach does not exist. zb4si15321910pbb.132 - gsmtp (in reply to RCPT TO command))" }

  describe ".create_from_line" do
    it "should extract and save relevant parts of the line" do
      email = Email.create!(postfix_queue_id: "39D9336AFA81")
      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.count.should == 1
      line = email.postfix_log_lines.first
      line.text.should == "to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
      line.time.should == Time.local(2013,4,5,16,41,54)
    end

    it "should save two lines if two lines are processed" do
      email = Email.create!(postfix_queue_id: "39D9336AFA81")
      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.create_from_line(line4)
      email.postfix_log_lines.count.should == 2
    end

    it "should not reprocess duplicate lines" do
      email = Email.create!(postfix_queue_id: "39D9336AFA81")
      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.create_from_line(line1)
      email.postfix_log_lines.count.should == 1
    end

    it "should not produce any log lines if the queue id is not recognised" do
      PostfixLogLine.should_receive(:puts).with("Skipping postfix queue id 39D9336AFA81 - it's not recognised")
      PostfixLogLine.create_from_line(line1)
      PostfixLogLine.count.should == 0
    end

    it "should only log lines that are delivery attempts" do
      PostfixLogLine.create_from_line(line2)
      PostfixLogLine.count.should == 0
    end
  end

  describe ".queue_id" do
    it { PostfixLogLine.queue_id(line1).should == "39D9336AFA81" }
    it { PostfixLogLine.queue_id(line2).should == "E69DB36D4A2B" }
    it { PostfixLogLine.queue_id(line3).should be_nil }
  end

  describe ".time" do
    it { PostfixLogLine.time(line1).should == Time.local(2013,4,5,16,41,54) }
    it { PostfixLogLine.time(line2).should == Time.local(2013,4,5,18,41,58) }
  end

  describe ".program" do
    it { PostfixLogLine.program(line1).should == "smtp" }
    it { PostfixLogLine.program(line2).should == "qmgr" }
  end

  describe ".program_content" do
    it { PostfixLogLine.program_content(line1).should == "to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))" }
    it { PostfixLogLine.program_content(line2).should == "removed" }
    it { PostfixLogLine.program_content(line3).should == "connect from unknown[111.142.251.143]"}
  end
end
