# frozen_string_literal: true

class AdminForm
  include ActiveModel::Model
  include Virtus.model

  attribute :email, String
end
