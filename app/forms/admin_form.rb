# frozen_string_literal: true

class AdminForm
  include ActiveModel::Model
  include Virtus.model

  attribute :email, String
  attribute :password, String
  attribute :name, String
  attribute :invitation_token, String
  attribute :reset_password_token, String
end
