# frozen_string_literal: true

class Team < ActiveRecord::Base
  has_many :admins
  has_many :apps
end
