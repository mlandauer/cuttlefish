# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :admins, dependent: :destroy
  has_many :apps, dependent: :destroy
end
