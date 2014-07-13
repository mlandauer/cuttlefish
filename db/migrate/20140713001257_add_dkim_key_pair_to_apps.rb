class AddDkimKeyPairToApps < ActiveRecord::Migration
  def change
    add_column :apps, :dkim_public_key, :text
    add_column :apps, :dkim_private_key, :text
  end
end
