# frozen_string_literal: true

class AddDkimKeyPairToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :dkim_public_key, :text
    add_column :apps, :dkim_private_key, :text
  end
end
