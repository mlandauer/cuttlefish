# frozen_string_literal: true

class RemoveDkimPublicKeyFromApps < ActiveRecord::Migration
  def change
    remove_column :apps, :dkim_public_key
  end
end
