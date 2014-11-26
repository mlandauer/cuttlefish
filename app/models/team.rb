class Team < ActiveRecord::Base
  has_many :admins
end
