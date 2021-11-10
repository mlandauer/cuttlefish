# frozen_string_literal: true

require "spec_helper"

describe EmailServices::Send do
  let(:email) do
    create(
      :email,
      to: "foo@bar.com",
      data: "from: contact@foo.com\nto: foo@bar.com\n\nMy original data"
    )
  end
  let(:send) { described_class.call(email: email) }

  it "opens an smtp connection to postfix port 25" do
    expect(Net::SMTP).to receive(:start).with("postfix", 25)

    send
  end

  it "sends an email with a return-path" do
    smtp = double
    expect_any_instance_of(Delivery).to receive(:return_path)
      .and_return("bounce-address@cuttlefish.io")
    expect(smtp).to receive(:send_message).with(
      anything,
      "bounce-address@cuttlefish.io",
      anything
    ).and_return(double(message: ""))
    expect(Net::SMTP).to receive(:start).and_yield(smtp)

    send
  end

  it "sends an email to foo@bar.com" do
    smtp = double
    expect(smtp).to receive(:send_message).with(
      anything,
      anything,
      ["foo@bar.com"]
    ).and_return(double(message: ""))
    expect(Net::SMTP).to receive(:start).and_yield(smtp)

    send
  end

  it "uses data to figure out what to send" do
    smtp = double
    filtered_mail = Mail.new do
      body "My altered data"
    end
    allow_any_instance_of(Filters::Master).to receive(:filter_mail)
      .and_return(filtered_mail)
    expect(smtp).to receive(:send_message).with(
      filtered_mail.to_s,
      anything,
      anything
    ).and_return(double(message: ""))
    expect(Net::SMTP).to receive(:start).and_yield(smtp)

    send
  end

  it "sets the postfix queue id on the deliveries based on the response from the server" do
    response = double(message: "250 2.0.0 Ok: queued as A123")
    smtp = double(send_message: response)
    allow(Net::SMTP).to receive(:start).and_yield(smtp)

    send

    email.deliveries.each { |d| expect(d.postfix_queue_id).to eq "A123" }
  end

  it "ignores response from server that doesn't include a queue id" do
    response = double(message: "250 250 Message accepted")
    smtp = double(send_message: response)
    allow(Net::SMTP).to receive(:start).and_yield(smtp)

    send

    email.deliveries.each { |d| expect(d.postfix_queue_id).to be_nil }
  end

  context "when deliveries is empty" do
    before do
      allow_any_instance_of(Delivery).to receive(:send?).and_return(false)
    end

    it "sends no emails" do
      # TODO: Ideally it shouldn't open a connection to the smtp server
      smtp = double
      expect(smtp).not_to receive(:send_message)
      allow(Net::SMTP).to receive(:start).and_yield(smtp)

      send
    end
  end

  context "when don't actually send anything" do
    before do
      smtp = double(send_message: double(message: ""))
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
    end

    it "records to which destinations the email has been sent" do
      expect(email.deliveries.first).not_to be_sent
    end

    it "records to which destinations the email has been sent" do
      send

      expect(email.deliveries.first).to be_sent
    end

    it "records that the deliveries are being open tracked" do
      send

      expect(email.deliveries.first).to be_open_tracked
    end

    context "when app has disabled open tracking" do
      before do
        email.app.update(open_tracking_enabled: false)
      end

      it "records that the deliveries are not being open tracked" do
        send

        expect(email.deliveries.first).not_to be_open_tracked
      end
    end
  end
end
