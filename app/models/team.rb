class Team < ActiveRecord::Base
  has_many :admins
  has_many :apps
  has_many :deny_lists
end
