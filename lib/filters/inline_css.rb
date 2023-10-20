# frozen_string_literal: true

module Filters
  class InlineCss < Filters::Mail
    def filter_html(input)
      Premailer.new(
        input,
        with_html_string: true,
        input_encoding: input.encoding.to_s,
        adapter: (html5?(input) ? :nokogumbo : :nokogiri)
      ).to_inline_css
    end
  end
end
