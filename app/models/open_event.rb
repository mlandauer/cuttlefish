class OpenEvent < ActiveRecord::Base
  belongs_to :delivery, counter_cache: true
  include UserAgent
end
