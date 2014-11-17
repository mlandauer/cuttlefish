class FixInvitationForAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :invitation_created_at, :datetime
    change_column :admins, :invitation_token, :string
  end
end
