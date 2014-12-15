require 'spec_helper'

describe Email do
  describe "create!" do
    context "One email is created" do
      before :each do
        FactoryGirl.create(:email,
          from: "matthew@foo.com",
          to: "foo@bar.com",
          data: "From: contact@openaustraliafoundation.org.au\nTo: Matthew Landauer\nSubject: This is a subject\nMessage-ID: <5161ba1c90b10_7837557029c754c8@kedumba.mail>\n\nHello!"
        )
      end

      it "should set the message-id based on the email content" do
        Email.first.message_id.should == "5161ba1c90b10_7837557029c754c8@kedumba.mail"
      end

      it "should set a hash of the full email content" do
        Email.first.data_hash.should == "d096b1b1dfbcabf6bd4ef4d4b0ad88f562eedee9"
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

      it "should set the subject of the email based on the data" do
        Email.first.subject.should == "This is a subject"
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
      EmailDataCache.any_instance.stub(:max_no_emails_to_store_data).and_return(2)
      4.times { FactoryGirl.create(:email, data: "This is a main section") }
      Dir.glob(File.join(EmailDataCache.new(Rails.env).data_filesystem_directory, "*")).count.should == 2
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
      it { email.html_part.encoding.to_s.should == "UTF-8"}
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

  context "an email which consistents of a part that is itself multipart" do
    let(:html_part) do
      Mail::Part.new do
        content_type  'text/html; charset=UTF-8'
        body '<p>This is some html</p>'
      end
    end
    let(:text_part) do
      Mail::Part.new do
        body 'This is plain text'
      end
    end
    let(:mail) do
      mail = Mail.new
      mail.part :content_type => "multipart/alternative" do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      mail
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { email.html_part.should == "<p>This is some html</p>" }
    end

    describe "#text_part" do
      it { email.text_part.should == 'This is plain text' }
    end
  end
end
