# frozen_string_literal: true

class RemoveDkimPublicKeyFromApps < ActiveRecord::Migration[4.2]
  def change
    remove_column :apps, :dkim_public_key
  end
end
