# frozen_string_literal: true

module AdminsHelper
  def email_with_name(admin)
    if admin.name.present?
      "#{admin.name} <#{admin.email}>"
    else
      admin.email
    end
  end
end
