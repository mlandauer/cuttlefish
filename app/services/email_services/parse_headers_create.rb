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
      new_data, ignore_deny_list, meta_values = parse_and_remove_special_headers

      EmailServices::CreateFromData.call(
        to: to,
        data: new_data,
        app_id: app_id,
        ignore_deny_list: ignore_deny_list,
        meta_values: meta_values
      )

      success!
    end

    IGNORE_DENY_LIST_HEADER = "X-Cuttlefish-Ignore-Deny-List"
    METADATA_HEADER_REGEX = /^X-Cuttlefish-Metadata-(.*)$/.freeze

    def parse_and_remove_special_headers
      mail = Mail.new(data)
      headers_to_remove = []
      ignore_deny_list = false
      meta_values = {}

      h = mail.header[IGNORE_DENY_LIST_HEADER]
      if h
        ignore_deny_list = (h.value == "true")
        headers_to_remove << IGNORE_DENY_LIST_HEADER
      end

      # Check for metadata headers
      mail.header_fields.each do |field|
        match = field.name.match(METADATA_HEADER_REGEX)
        if match
          meta_values[match[1]] = field.value
          headers_to_remove << field.name
        end
      end

      # Remove headers at the end
      headers_to_remove.each { |name| mail.header[name] = nil }

      [mail.to_s, ignore_deny_list, meta_values]
    end

    private

    attr_reader :to, :data, :app_id
  end
end
