require 'spec_helper'

describe Email do
  describe "create!" do
    it "should set the default app if none is given" do
      email = FactoryGirl.create(:email, app_id: nil)
      email.app.should be_default_app
    end

    context "One email is created" do
      before :each do
        FactoryGirl.create(:email,
          from: "matthew@foo.com",
          to: "foo@bar.com",
          data: "From: contact@openaustraliafoundation.org.au\nTo: Matthew Landauer\nMessage-ID: <5161ba1c90b10_7837557029c754c8@kedumba.mail>\n\nHello!"
        )
      end

      it "should set the message-id based on the email content" do
        Email.first.message_id.should == "5161ba1c90b10_7837557029c754c8@kedumba.mail"
      end

      it "should set a hash of the full email content" do
        Email.first.data_hash.should == "8807e1b5f635e050b5d84634cfb9a37f9c1bd2e4"
      end

      it "should have an identical hash to another email with identical content" do
        first_email = Email.first
        email = FactoryGirl.create(:email, from: "geoff@foo.com", to: "people@bar.com", data: first_email.data)
        email.data_hash.should == first_email.data_hash
      end

      it "should have a different hash to another email with different content" do
        first_email = Email.first
        email = FactoryGirl.create(:email, from: "geoff@foo.com", to: "people@bar.com", data: "Something else")
        email.data_hash.should_not == first_email.data_hash
      end
    end
  end

  describe "#from" do
    it "should return a string for the from email address" do
      email = FactoryGirl.create(:email, from_address: Address.create!(text: "matthew@foo.com"))
      email.from.should == "matthew@foo.com"
    end

    it "should allow the from_address to be set by a string" do
      email = FactoryGirl.create(:email, from: "matthew@foo.com")
      email.from.should == "matthew@foo.com"
    end
  end

  describe "#from_address" do
    it "should return an Address object" do
      email = FactoryGirl.create(:email, from: "matthew@foo.org")
      a1 = Address.find_by_text("matthew@foo.org")
      a1.should_not be_nil
      email.from_address.should == a1
    end
  end

  describe "#to" do
    it "should return an array for all the email addresses" do
      email = FactoryGirl.create(:email, to: ["mlandauer@foo.org", "matthew@bar.com"])
      email.to.should == ["mlandauer@foo.org", "matthew@bar.com"]
    end

    it "should be able to give just a single recipient" do
      email = Email.new(to: "mlandauer@foo.org")
      email.to.should == ["mlandauer@foo.org"]
    end

    it "should set created_at for deliveries too" do
      email = FactoryGirl.create(:email, to: "mlandauer@foo.org")
      email.deliveries.first.created_at.should_not be_nil      
    end
  end

  describe "#to_addresses" do
    it "should return an array of Address objects" do
      email = FactoryGirl.create(:email, to: ["mlandauer@foo.org", "matthew@bar.com"])
      a1 = Address.find_by_text("mlandauer@foo.org")
      a2 = Address.find_by_text("matthew@bar.com")
      a1.should_not be_nil
      a2.should_not be_nil
      email.to_addresses.should == [a1, a2]
    end
  end

  describe "#data" do
    context "one email" do
      before :each do
        FactoryGirl.create(:email, id: 10, data: "This is a main data section")
      end
      let(:email) { Email.find(10) }
      
      it "should be able to read in the data again" do
        email.data.should == "This is a main data section"
      end

      it "should be able to read in the data again even after being saved again" do
        email.save!
        email.data.should == "This is a main data section"
      end
    end

    it "should only keep the full data of a certain number of the emails around" do
      EmailDataCache.stub!(:max_no_emails_to_store_data).and_return(2)
      4.times { FactoryGirl.create(:email, data: "This is a main section") }
      Dir.glob(File.join(EmailDataCache.data_filesystem_directory, "*")).count.should == 2
    end
  end

  describe "#update_status" do
    it "should set the attribute based on calculated_status" do
      email = Email.new
      calculated_status = mock
      email.should_receive(:calculated_status).and_return(calculated_status)
      email.should_receive(:update_attribute).with(:status, calculated_status)

      email.update_status!
    end
  end

  describe "#status" do
    it { FactoryGirl.create(:email).status.should == "not_sent" }
  end

  describe "#calculated_status" do
    context "an email with one recipient" do
      # TODO: It's time to start using factories
      let(:address) { Address.create!(text: "matthew@foo.com")}
      let(:email) { FactoryGirl.create(:email, to_addresses: [address]) }
      let(:delivery) { Delivery.find_by(email: email, address: address)}

      context "email is sent" do
        before :each do
          delivery.update_attribute(:sent, true)
        end

        it "should be delivered if the status is sent" do
          delivery.postfix_log_lines.create(dsn: "2.0.0")
          email.calculated_status.should == "delivered"
        end

        it "should not be delivered if the status is deferred" do
          delivery.postfix_log_lines.create(dsn: "4.3.0")
          email.calculated_status.should == "soft_bounce"
        end
      end

      it "should start in a state of not sent" do
        email.calculated_status.should == "not_sent"
      end
    end

    context "an email with two recipients" do
      let(:address_matthew) { Address.create!(text: "matthew@foo.com") }
      let(:address_greg) { Address.create!(text: "greg@foo.com")}
      let(:email) { FactoryGirl.create(:email, to_addresses: [address_matthew, address_greg]) }
      let(:delivery_matthew) { Delivery.find_by(email: email, address: address_matthew) }
      let(:delivery_greg) { Delivery.find_by(email: email, address: address_greg) }
      before :each do
        delivery_matthew.update_attribute(:sent, true)
        delivery_greg.update_attribute(:sent, true)
      end

      it "should have an unknown delivery status if we only have one log entry" do
        delivery_matthew.postfix_log_lines.create(dsn: "2.0.0")
        email.calculated_status.should == "unknown"
      end

      it "should know it's delivered if there are two succesful deliveries in the logs" do
        delivery_matthew.postfix_log_lines.create(dsn: "2.0.0")
        delivery_greg.postfix_log_lines.create(dsn: "2.0.0")
        email.calculated_status.should == "delivered"
      end

      it "should be in an unknown state if there are two log entries from the same email address" do
        delivery_matthew.postfix_log_lines.create(dsn: "4.3.0")
        delivery_matthew.postfix_log_lines.create(dsn: "2.0.0")
        email.calculated_status.should == "unknown"
      end
    end
  end

  context "an email with a text part and an html part" do
    let(:mail) do
      Mail.new do
        text_part do
          body 'This is plain text'
        end

        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1>'
        end
      end
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { email.html_part.should == "<h1>This is HTML</h1>" }
    end

    describe "#text_part" do
      it { email.text_part.should == "This is plain text" }
    end
  end

  context "an email which just consistents of a single text part" do
    let(:mail) do
      Mail.new do
        body 'This is plain text'
      end
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { email.html_part.should be_nil }
    end

    describe "#text_part" do
      it { email.text_part.should == "This is plain text" }
    end
  end

  context "an email which just consistents of a single html part" do
    let(:mail) do
      Mail.new do
        content_type 'text/html; charset=UTF-8'
        body '<p>This is some html</p>'
      end
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { email.html_part.should == "<p>This is some html</p>" }
    end

    describe "#text_part" do
      it { email.text_part.should be_nil }
    end
  end
end
