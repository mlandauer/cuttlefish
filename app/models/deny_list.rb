# frozen_string_literal: true

class DenyList < ApplicationRecord
  belongs_to :app
  belongs_to :address
  belongs_to :caused_by_postfix_log_line, class_name: "PostfixLogLine"
end
