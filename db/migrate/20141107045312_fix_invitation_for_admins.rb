# frozen_string_literal: true

class FixInvitationForAdmins < ActiveRecord::Migration[4.2]
  def change
    add_column :admins, :invitation_created_at, :datetime
    change_column :admins, :invitation_token, :string
  end
end
