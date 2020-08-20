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
      new_data, ignore_deny_list, meta_values = parse_and_remove_headers

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

    def parse_and_remove_headers
      # Parse for special headers
      m = Mail.new(data)
      h = m.header[IGNORE_DENY_LIST_HEADER]
      ignore_deny_list = (!h.nil? && h.value == "true")

      # Remove header
      m.header[IGNORE_DENY_LIST_HEADER] = nil if m.header[IGNORE_DENY_LIST_HEADER]

      # Check for metadata headers
      meta_values = {}
      names = []
      m.header_fields.each do |field|
        match = field.name.match(METADATA_HEADER_REGEX)
        if match
          meta_values[match[1]] = field.value
          names << field.name
        end
      end

      # Remove headers
      names.each { |name| m.header[name] = nil }

      [m.to_s, ignore_deny_list, meta_values]
    end

    private

    attr_reader :to, :data, :app_id
  end
end
