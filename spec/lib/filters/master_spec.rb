require "spec_helper"

describe Filters::Master do
  let(:mail) do
    Mail.new do
      from "matthew@foo.com"
      html_part do
        content_type "text/html; charset=iso-8859-2"
        body "<p>vašem</p>".encode(Encoding::ISO_8859_2)
      end
    end
  end

  it do
    app = App.create!(name: "Test")
    email = Email.create!(app_id: app.id)
    delivery = Delivery.create!(email: email, app: app)
    mail2 = Filters::Master.new(delivery).filter_mail(mail)
    expect(Nokogiri::HTML(mail2.html_part.decoded).at("p").inner_text).to eq "vašem"
  end
end
