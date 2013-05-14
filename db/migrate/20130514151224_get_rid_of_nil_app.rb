class GetRidOfNilApp < ActiveRecord::Migration
  def change
    Email.where(app_id: nil).update_all("app_id = #{App.cuttlefish.id}")
    change_column :emails, :app_id, :integer, null: false
  end
end
