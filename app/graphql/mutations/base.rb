# frozen_string_literal: true

module Mutations
  class Base < GraphQL::Schema::Mutation
    def user_errors_from_form_errors(errors, root_path)
      user_errors = []
      # Convert Rails model errors into GraphQL-ready error hashes
      errors.attribute_names.each do |attribute|
        m = errors.messages[attribute]
        d = errors.details[attribute]
        m.zip(d).each do |message, detail|
          # This is the GraphQL argument which corresponds to the
          # validation error:
          path = root_path + [attribute.to_s.camelize(:lower)]
          user_errors << {
            path: path,
            message: message,
            type: detail[:error].to_s.upcase
          }
        end
      end
      user_errors
    end
  end
end
