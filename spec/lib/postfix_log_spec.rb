require "spec_helper"

describe PostfixLog do
  describe ".process" do
    it "should extract and save relevant parts of the line" do
      email = Email.create!(postfix_queue_id: "39D9336AFA81")
      PostfixLog.process("Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))")
      email.postfix_log_lines.first.text.should == "Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))"
    end
  end

  describe ".extract_postfix_queue_id_from_line" do
    it { PostfixLog.extract_postfix_queue_id_from_line("Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))").should == "39D9336AFA81" }
    it { PostfixLog.extract_postfix_queue_id_from_line("Apr  5 18:41:58 kedumba postfix/qmgr[2638]: E69DB36D4A2B: removed").should == "E69DB36D4A2B" }
    it { PostfixLog.extract_postfix_queue_id_from_line("Apr  5 17:11:07 kedumba postfix/smtpd[7453]: connect from unknown[111.142.251.143]").should be_nil }
  end

  describe ".extract_time_from_postfix_log_line" do
    it { PostfixLog.extract_time_from_postfix_log_line("Apr  5 16:41:54 kedumba postfix/smtp[18733]: 39D9336AFA81: to=<foo@bar.com>, relay=foo.bar.com[1.2.3.4]:25, delay=92780, delays=92777/0.03/1.6/0.91, dsn=4.3.0, status=deferred (host foo.bar.com[1.2.3.4] said: 451 4.3.0 <bounces@planningalerts.org.au>: Temporary lookup failure (in reply to RCPT TO command))").should == Time.local(2013, 4, 5, 16, 41, 54) }
    it { PostfixLog.extract_time_from_postfix_log_line("Apr  5 18:41:58 kedumba postfix/qmgr[2638]: E69DB36D4A2B: removed").should == Time.local(2013, 4, 5, 18, 41, 58) }
  end
end