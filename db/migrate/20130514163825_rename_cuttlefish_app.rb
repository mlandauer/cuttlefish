# frozen_string_literal: true

class RenameCuttlefishApp < ActiveRecord::Migration
  def change
    # This doesn't work anymore because App.default will fail at this
    # stage in the migrations. Could fix this properly but there is no
    # advantage to it. Instead just commenting out
    #App.default.update_attributes(name: "Default", url: nil)
  end
end
