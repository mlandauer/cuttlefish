class RemoveLimitOnUrlLength < ActiveRecord::Migration[5.2]
  def change
    change_column :links, :url, :string, limit: nil, null: false
  end
end
