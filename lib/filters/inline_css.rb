# frozen_string_literal: true

module Filters
  class InlineCss < Filters::Mail
    def filter_html(input)
      TransformHtml.new(input).inline_css
    end
  end
end
