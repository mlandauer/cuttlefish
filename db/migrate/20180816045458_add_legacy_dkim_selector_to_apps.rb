class AddLegacyDkimSelectorToApps < ActiveRecord::Migration[5.2]
  class App < ActiveRecord::Base
  end

  def change
    add_column :apps, :legacy_dkim_selector, :boolean, null: false, default: false
    reversible do |dir|
      dir.up do
        App.where(dkim_enabled: true).update_all(legacy_dkim_selector: true)
      end
    end
  end
end
