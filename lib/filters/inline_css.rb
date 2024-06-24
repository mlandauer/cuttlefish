# frozen_string_literal: true

module Filters
  class InlineCss < Filters::Mail
    attr_accessor :enabled

    def initialize(enabled:)
      super()
      @enabled = enabled
    end

    def filter_html(input)
      if enabled
        TransformHtml.new(input).inline_css
      else
        input
      end
    end
  end
end
