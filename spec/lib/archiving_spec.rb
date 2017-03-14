require "spec_helper"

describe Archiving do
  let(:app) do
    FactoryGirl.create(:team).apps.create!(
      id: 2,
      name: "Planning Alerts",
      from_domain: "planningalerts.org.au"
    )
  end
  let(:email) do
    app.emails.create!(
      id: 1753541,
      from_address: Address.create!( id: 12, text: "bounces@planningalerts.org.au"),
      data_hash: "aa126db79482378ce17b441347926570228f12ef",
      message_id: "538ef46757549_443e4bb0f901893332@kedumba.mail",
      subject: "1 new planning application"
    )
  end

  describe ".serialise" do
    let(:link1) { Link.create!(id: 123, url: "http://www.planningalerts.org.au/alerts/abc1234/area") }
    let(:link2) { Link.create!(id: 321, url: "http://www.planningalerts.org.au/alerts/abc1234/unsubscribe") }
    let(:click_event) { ClickEvent.create!(user_agent: "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:24.0) Gecko/20100101 Firefox/24.0", ip: "1.2.3.4", created_at: "2014-06-04T20:33:53.000+10:00") }
    let(:delivery) do
      Delivery.create!(
        id: 5,
        email: email,
        address: Address.create!(id: 13, text: "foo@gmail.com"),
        created_at: "2014-06-04T20:26:51.000+10:00",
        updated_at: "2014-06-04T20:26:55.000+10:00",
        sent: true,
        status: "delivered",
        open_tracked: true,
        postfix_queue_id: "38B72370AC41"
      )
    end

    before do
      delivery.open_events.create!(
        user_agent: "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (via ggpht.com GoogleImageProxy)",
        ip: "2.3.4.5",
        created_at: "2014-10-06T16:05:52.000+11:00"
      )
      delivery.delivery_links.create!(link: link1, click_events: [])
      delivery.delivery_links.create!(link: link2, click_events: [click_event])
      delivery.postfix_log_lines.create!(
        time: "2014-06-04T20:26:53.000+10:00",
        relay: "gmail-smtp-in.l.google.com[173.194.79.26]:25",
        delay: "1.7",
        delays: "0.05/0/0.58/1",
        dsn: "2.0.0",
        extended_status: "sent (250 2.0.0 OK 1401877617 bh2si4687161pbb.204 - gsmtp)"
      )
    end

    it "produces the same results with a Delivery object created directly as one created with .deserialise from a previously serialised Delivery" do
      s1 = Archiving.serialise(delivery)

      delivery.destroy
      delivery = Archiving.deserialise(s1)
      s2 = Archiving.serialise(delivery)

      expect(s1).to eq s2
    end
  end

  describe ".archive" do
    around do |example|
      # Silence debugging output from this method
      silence_stream(STDOUT) do
        example.run
      end
    end

    it "removes the temp archive file it creates" do
      # TODO: We don't care about which email this is assigned to, so don't assign it
      FactoryGirl.create(:delivery, created_at: "2014-06-04T20:26:51.000+10:00", email: email)

      Archiving.archive("2014-06-04")

      expect { File.open("db/archive/2014-06-04.tar.gz") }.to raise_exception.with_message /No such file or directory/
    end

    context "when uploading to S3 doesn't happen" do
      pending "don't delete the local copy" do
        fail
      end
    end
  end

  describe ".copy_to_s3" do
    around do |example|
      # Silence debugging output from this method
      silence_stream(STDOUT) do
        example.run
      end
    end

    context "when AWS access is configured" do
      around do |test|
        with_modified_env mock_aws_credentials do
          test.run
        end
      end

      before do
        fixture_archive_file = File.open("spec/fixtures/archive/2014-06-04.tar.gz")
        allow(File).to receive(:open).with("db/archive/2014-06-04.tar.gz") { fixture_archive_file }
      end

      it "sends a copy to S3" do
        VCR.use_cassette("aws") do
          expect(Archiving.copy_to_s3("2014-06-04")).to be_instance_of Fog::Storage::AWS::File
        end
      end
    end

    context "when AWS access is not configured" do
      around do |test|
        with_modified_env aws_credentials_missing do
          test.run
        end
      end

      it "fails silently" do
        expect(Archiving.copy_to_s3("2014-06-04")).to eq nil
      end
    end

    pending "does something useful when the upload fails" do
      fail "it probably raises an error currently, but I don't know"
    end

    pending "does something useful when the file isn't there to upload" do
      fail "it probably raises an error currently, but I don't know"
    end
  end
end

def mock_aws_credentials
  {
    S3_BUCKET: "fake-s3-bucket",
    AWS_ACCESS_KEY_ID: "fake-aws-access-key-id",
    AWS_SECRET_ACCESS_KEY: "fake-aws-secret-access-key"
  }
end

def aws_credentials_missing
  {
    S3_BUCKET: nil,
    AWS_ACCESS_KEY_ID: nil,
    AWS_SECRET_ACCESS_KEY: nil
  }
end

def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end
