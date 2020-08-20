# frozen_string_literal: true

module EmailServices
  class ParseHeadersCreate < ApplicationService
    def initialize(to:, data:, app_id:)
      super()
      @to = to
      @data = data
      @app_id = app_id
    end

    IGNORE_DENY_LIST_HEADER = "X-Cuttlefish-Ignore-Deny-List"

    # Note that this service depends on having access to the same filesystem as
    # the worker processes have access to. Currently, that's fine because we're
    # running everything on a single machine but that assumption might not be
    # true in the future
    def call
      # Parse for special headers
      m = Mail.new(data)
      h = m.header[IGNORE_DENY_LIST_HEADER]
      ignore_deny_list = (!h.nil? && h.value == "true")

      # Remove header
      m.header[IGNORE_DENY_LIST_HEADER] = nil if m.header[IGNORE_DENY_LIST_HEADER]

      # Check for metadata headers that start with "X-Cuttlefish-Metadata-"
      meta_values = {}
      names = []
      m.header_fields.each do |field|
        match = field.name.match(/^X-Cuttlefish-Metadata-(.*)$/)
        if match
          meta_values[match[1]] = field.value
          names << field.name
        end
      end

      # Remove headers
      names.each { |name| m.header[name] = nil }

      EmailServices::CreateFromData.call(
        to: to,
        data: m.to_s,
        app_id: app_id,
        ignore_deny_list: ignore_deny_list,
        meta_values: meta_values
      )

      success!
    end

    private

    attr_reader :to, :data, :app_id
  end
end
