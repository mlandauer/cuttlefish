require 'spec_helper'

describe Email do
  describe "create!" do
    context "One email is created" do
      before :each do
        Email.create!(
          :from => "matthew@foo.com",
          :to => "foo@bar.com",
          :data => "From: contact@openaustraliafoundation.org.au\nTo: Matthew Landauer\nMessage-ID: <5161ba1c90b10_7837557029c754c8@kedumba.mail>\n\nHello!"
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
        email = Email.create!(from: "geoff@foo.com", to: "people@bar.com", data: first_email.data)
        email.data_hash.should == first_email.data_hash
      end

      it "should have a different hash to another email with different content" do
        first_email = Email.first
        email = Email.create!(from: "geoff@foo.com", to: "people@bar.com", data: "Something else")
        email.data_hash.should_not == first_email.data_hash
      end
    end
  end

  describe "#from" do
    it "should return a string for the from email address" do
      email = Email.create!(:from_address => Address.create!(text: "matthew@foo.com"))
      email.from.should == "matthew@foo.com"
    end

    it "should allow the from_address to be set by a string" do
      email = Email.create!(:from => "matthew@foo.com")
      email.from.should == "matthew@foo.com"
    end
  end

  describe "#from_address" do
    it "should return an Address object" do
      email = Email.create!(from: "matthew@foo.org")
      a1 = Address.find_by_text("matthew@foo.org")
      a1.should_not be_nil
      email.from_address.should == a1
    end
  end

  describe "#to" do
    it "should return an array for all the email addresses" do
      email = Email.create!(:to => ["mlandauer@foo.org", "matthew@bar.com"])
      email.to.should == ["mlandauer@foo.org", "matthew@bar.com"]
    end

    it "should be able to give just a single recipient" do
      email = Email.new(:to => "mlandauer@foo.org")
      email.to.should == ["mlandauer@foo.org"]
    end
  end

  describe "#to_addresses" do
    it "should return an array of Address objects" do
      email = Email.create!(to: ["mlandauer@foo.org", "matthew@bar.com"])
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
        @email = Email.create!(id: 10, data: "This is a main data section")
      end
      
      it "should persist the main part of the email in the filesystem" do
        File.read(@email.data_filesystem_path).should == "This is a main data section"
      end

      it "should be able to read in the data again" do
        Email.find(10).data.should == "This is a main data section"
      end

      it "should be able to read in the data again even after being saved again" do
        email = Email.find(10)
        email.save!
        email.data.should == "This is a main data section"
      end

      it "should return nil if nothing is stored on the filesystem" do
        FileUtils::rm_rf(Email.data_filesystem_directory)
        Email.find(10).data.should be_nil
      end
    end

    it "should only keep the full data of a certain number of the emails around" do
      Email.stub!(:max_no_emails_to_store_data).and_return(2)
      4.times { Email.create!(data: "This is a main section") }
      Dir.glob(File.join(Email.data_filesystem_directory, "*")).count.should == 2
    end
  end

  describe ".extract_postfix_queue_id_from_smtp_message" do
    it "should extract the queue id" do
      Email.extract_postfix_queue_id_from_smtp_message("250 2.0.0 Ok: queued as 2F63736D4A27\n").should == "2F63736D4A27"
    end

    it "should ignore any other form" do
      Email.extract_postfix_queue_id_from_smtp_message("250 250 Message accepted").should be_nil
    end
  end

  describe "#update_delivery_status!" do
    context "an email with one recipient" do
      let(:email) { Email.create!(:to => "matthew@foo.com") }

      it "should have an unknown delivery status before anything is done" do
        email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "2.0.0")
        email.delivered.should be_nil
      end

      it "should be delivered if the status is sent" do
        email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "2.0.0", delivery: email.deliveries.first)
        email.update_delivery_status!
        email.delivered.should == true
      end

      it "should not be delivered if the status is deferred" do
        email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "4.3.0", delivery: email.deliveries.first)
        email.update_delivery_status!
        email.delivered.should == false
      end

      it "should not update the delivery status if there are no log lines" do
        email.update_delivery_status!
        email.delivered.should be_nil
      end
    end

    context "an email with two recipients" do
      let(:email) { Email.create!(:to => ["matthew@foo.com", "greg@foo.com"]) }

      it "should have an unknown delivery status if we only have one log entry" do
        email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "2.0.0")
        email.update_delivery_status!
        email.delivered.should be_nil
      end

      it "should know it's delivered if there are two succesful deliveries in the logs" do
        email
        address_matthew = Address.find_by_text("matthew@foo.com")
        address_greg = Address.find_by_text("greg@foo.com")
        delivery_matthew = Delivery.find_by_address_id(address_matthew.id)
        delivery_greg = Delivery.find_by_address_id(address_greg.id)
        email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "2.0.0", delivery: delivery_matthew)
        email.postfix_log_lines.create(to: "greg@foo.com", dsn: "2.0.0", delivery: delivery_greg)
        email.update_delivery_status!
        email.delivered.should == true
      end

      it "should be in an unknown state if there are two log entries from the same email address" do
        email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "4.3.0")
        email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "2.0.0")
        email.update_delivery_status!
        email.delivered.should be_nil
      end
    end
  end
end
