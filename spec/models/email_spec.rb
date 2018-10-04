# frozen_string_literal: true

require "spec_helper"

describe Email do
  describe "create!" do
    context "One email is created" do
      before :each do
        create(
          :email,
          to: "foo@bar.com",
          data:
            "From: contact@openaustraliafoundation.org.au\n" \
            "To: Matthew Landauer\n" \
            "Subject: This is a subject\n" \
            "Message-ID: <5161ba1c90b10_7837557029c754c8@kedumba.mail>\n" \
            "\n" \
            "Hello!"
        )
      end

      it "should set the message-id based on the email content" do
        expect(Email.first.message_id).to eq(
          "5161ba1c90b10_7837557029c754c8@kedumba.mail"
        )
      end

      it "should set a hash of the full email content" do
        expect(Email.first.data_hash).to eq(
          "d096b1b1dfbcabf6bd4ef4d4b0ad88f562eedee9"
        )
      end

      it "should have the same hash as other email with identical content" do
        first_email = Email.first
        email = create(
          :email,
          from: "geoff@foo.com",
          to: "people@bar.com",
          data: first_email.data
        )
        expect(email.data_hash).to eq first_email.data_hash
      end

      it "should have a different hash to other email with different content" do
        first_email = Email.first
        email = create(
          :email,
          from: "geoff@foo.com",
          to: "people@bar.com",
          data: "Something else"
        )
        expect(email.data_hash).to_not eq first_email.data_hash
      end

      it "should set the subject of the email based on the data" do
        expect(Email.first.subject).to eq "This is a subject"
      end

      it "should set the from address based on the content of the email" do
        expect(Email.first.from).to eq "contact@openaustraliafoundation.org.au"
      end
    end
  end

  describe "#from" do
    it "should return a string for the from email address" do
      email = create(
        :email,
        from_address: Address.create!(text: "matthew@foo.com")
      )
      expect(email.from).to eq "matthew@foo.com"
    end

    it "should allow the from_address to be set by a string" do
      email = create(:email, from: "matthew@foo.com")
      expect(email.from).to eq "matthew@foo.com"
    end
  end

  describe "#from_address" do
    it "should return an Address object" do
      email = create(:email, from: "matthew@foo.org")
      a1 = Address.find_by_text("matthew@foo.org")
      expect(a1).to_not be_nil
      expect(email.from_address).to eq a1
    end
  end

  describe "#to" do
    it "should return an array for all the email addresses" do
      email = create(
        :email,
        to: ["mlandauer@foo.org", "matthew@bar.com"]
      )
      expect(email.to).to eq ["mlandauer@foo.org", "matthew@bar.com"]
    end

    it "should be able to give just a single recipient" do
      email = Email.new(to: "mlandauer@foo.org")
      expect(email.to).to eq ["mlandauer@foo.org"]
    end

    it "should set created_at for deliveries too" do
      email = create(:email, to: "mlandauer@foo.org")
      expect(email.deliveries.first.created_at).to_not be_nil
    end
  end

  describe "#to_addresses" do
    it "should return an array of Address objects" do
      email = create(
        :email,
        to: ["mlandauer@foo.org", "matthew@bar.com"]
      )
      a1 = Address.find_by_text("mlandauer@foo.org")
      a2 = Address.find_by_text("matthew@bar.com")
      expect(a1).to_not be_nil
      expect(a2).to_not be_nil
      expect(email.to_addresses).to eq [a1, a2]
    end
  end

  describe "#data" do
    context "one email" do
      before :each do
        create(:email, id: 10, data: "This is a main data section")
      end
      let(:email) { Email.find(10) }

      it "should be able to read in the data again" do
        expect(email.data).to eq "This is a main data section"
      end

      it "should be able to read in the data again after being saved again" do
        email.save!
        expect(email.data).to eq "This is a main data section"
      end
    end

    it "should only keep the full data of a certain number of emails around" do
      allow(Rails.configuration).to receive(
        :max_no_emails_to_store
      ).and_return(2)
      app = create(:app)
      4.times do
        create(
          :email, data: "This is a main section", app_id: app.id
        )
      end
      expect(
        Dir.glob(
          File.join(Email.first.email_cache.data_filesystem_directory, "*")
        ).count
      ).to eq 2
    end
  end

  context "an email with a text part and an html part" do
    let(:mail) do
      Mail.new do
        text_part do
          body "This is plain text"
        end

        html_part do
          content_type "text/html; charset=UTF-8"
          body "<h1>This is HTML</h1>"
        end
      end
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { expect(email.html_part).to eq "<h1>This is HTML</h1>" }
      it { expect(email.html_part.encoding.to_s).to eq "UTF-8" }
    end

    describe "#text_part" do
      it { expect(email.text_part).to eq "This is plain text" }
    end
  end

  context "an email which just consistents of a single text part" do
    let(:mail) do
      Mail.new do
        body "This is plain text"
      end
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { expect(email.html_part).to be_nil }
    end

    describe "#text_part" do
      it { expect(email.text_part).to eq "This is plain text" }
    end
  end

  context "another email which is just a single text part" do
    let(:data) do
      <<~DATA
        To: web-administrators@openaustralia.org
        Subject: Email alert statistics
        From: Email Alerts <contact@openaustralia.org>

        Some text
      DATA
    end

    let(:email) do
      Email.new(data: data)
    end

    describe "#text_part" do
      it { expect(email.text_part).to eq "Some text\n" }
    end
  end

  context "an email which just consistents of a single html part" do
    let(:mail) do
      Mail.new do
        content_type "text/html; charset=UTF-8"
        body "<p>This is some html</p>"
      end
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { expect(email.html_part).to eq "<p>This is some html</p>" }
    end

    describe "#text_part" do
      it { expect(email.text_part).to be_nil }
    end
  end

  context "an email which consistents of a part that is itself multipart" do
    let(:html_part) do
      Mail::Part.new do
        content_type  "text/html; charset=UTF-8"
        body "<p>This is some html</p>"
      end
    end
    let(:text_part) do
      Mail::Part.new do
        body "This is plain text"
      end
    end
    let(:mail) do
      mail = Mail.new
      mail.part content_type: "multipart/alternative" do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      mail
    end
    let(:email) do
      Email.new(data: mail.encoded)
    end

    describe "#html_part" do
      it { expect(email.html_part).to eq "<p>This is some html</p>" }
    end

    describe "#text_part" do
      it { expect(email.text_part).to eq "This is plain text" }
    end
  end
end
