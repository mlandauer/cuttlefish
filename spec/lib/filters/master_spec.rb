# frozen_string_literal: true

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
    mail2 = Filters::Master.new(delivery: create(:delivery)).filter_mail(mail)
    expect(Nokogiri::HTML(mail2.html_part.decoded).at("p").inner_text).to eq(
      "vašem"
    )
  end
end
