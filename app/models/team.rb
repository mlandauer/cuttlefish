# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :admins
  has_many :apps
end
