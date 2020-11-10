class RemoveAdminsApiKey < ActiveRecord::Migration[5.2]
  def change
    remove_column :admins, :api_key, :string
  end
end
