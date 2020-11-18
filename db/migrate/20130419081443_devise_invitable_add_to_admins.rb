# frozen_string_literal: true

class DeviseInvitableAddToAdmins < ActiveRecord::Migration[4.2]
  def up
    change_table :admins do |t|
      t.string     :invitation_token, limit: 60
      t.datetime   :invitation_sent_at
      t.datetime   :invitation_accepted_at
      t.integer    :invitation_limit
      t.references :invited_by, polymorphic: true
      t.index      :invitation_token, unique: true # for invitable
      t.index      :invited_by_id
    end

    # And allow null encrypted_password and password_salt:
    change_column_null :admins, :encrypted_password, true
  end

  def down
    change_table :admins do |t|
      t.remove_references :invited_by, polymorphic: true
      t.remove :invitation_limit, :invitation_sent_at, :invitation_accepted_at, :invitation_token
    end
  end
end
