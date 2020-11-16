# frozen_string_literal: true

class GetRidOfNilApp < ActiveRecord::Migration[4.2]
  def change
    # This doesn't work anymore because App.default will fail at this
    # stage in the migrations. Could fix this properly but there is no
    # advantage to it. Instead just commenting out
    #Email.where(app_id: nil).update_all("app_id = #{App.default.id}")
    change_column :emails, :app_id, :integer, null: false
  end
end
