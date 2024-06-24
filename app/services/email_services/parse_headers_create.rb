# frozen_string_literal: true

module EmailServices
  class ParseHeadersCreate < ApplicationService
    def initialize(to:, data:, app_id:)
      super()
      @to = to
      @data = data
      @app_id = app_id
    end

    def call
      new_data, options = parse_and_remove_special_headers

      EmailServices::CreateFromData.call(
        to: to,
        data: new_data,
        app_id: app_id,
        ignore_deny_list: options[:ignore_deny_list],
        meta_values: options[:meta_values]
      )

      success!
    end

    IGNORE_DENY_LIST_HEADER = "X-Cuttlefish-Ignore-Deny-List"
    DISABLE_CSS_INLINING_HEADER = "X-Cuttlefish-Disable-Css-Inlining"
    METADATA_HEADER_REGEX = /^X-Cuttlefish-Metadata-(.*)$/

    def parse_and_remove_special_headers
      mail = Mail.new(data)
      headers_to_remove = []
      options = { ignore_deny_list: false, disable_css_inlining: false, meta_values: {} }

      h = mail.header[IGNORE_DENY_LIST_HEADER]
      if h
        options[:ignore_deny_list] = (h.value == "true")
        headers_to_remove << IGNORE_DENY_LIST_HEADER
      end

      h = mail.header[DISABLE_CSS_INLINING_HEADER]
      if h
        options[:disable_css_inlining] = (h.value == "true")
        headers_to_remove << DISABLE_CSS_INLINING_HEADER
      end

      # Check for metadata headers
      mail.header_fields.each do |field|
        match = field.name.match(METADATA_HEADER_REGEX)
        if match
          options[:meta_values][match[1]] = field.value
          headers_to_remove << field.name
        end
      end

      # Remove headers at the end
      mail.header_fields.delete_if { |field| headers_to_remove.include?(field.name) }

      [mail.to_s, options]
    end

    private

    attr_reader :to, :data, :app_id
  end
end
