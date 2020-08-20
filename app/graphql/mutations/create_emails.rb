# frozen_string_literal: true

module Mutations
  class CreateEmails < Mutations::Base
    null true

    # TODO: Give descriptions for arguments and fields
    argument :app_id, ID, required: true

    # TODO: Make this an email address and name
    argument :from, String, required: true
    # TODO: Make this an array of email addresses and names
    argument :to, [String], required: true
    # TODO: Make this an array of email addresses and names
    argument :cc, [String], required: false
    argument :subject, String, required: true

    # TODO: Wrap this up in a content type
    argument :text_part, String, required: false
    argument :html_part, String, required: false

    argument :ignore_deny_list, Boolean, required: false
    argument :meta_values, [Types::KeyValueAttributes], required: false

    field :emails, [Types::Email], null: true

    # rubocop:disable Naming/MethodParameterName
    def resolve(
      app_id:, from:, to:, cc: [], subject:, text_part: nil, html_part: nil,
      ignore_deny_list: false, meta_values: []
    )
      create_email = EmailServices::Create.call(
        app_id: app_id,
        from: from,
        to: to,
        cc: cc,
        subject: subject,
        text_part: text_part,
        html_part: html_part,
        ignore_deny_list: ignore_deny_list,
        meta_values: Hash[meta_values.map { |m| [m.key, m.value] }]
      )
      # TODO: Error checking
      {
        emails: create_email.result.deliveries
      }
    end
    # rubocop:enable Naming/MethodParameterName
  end
end
