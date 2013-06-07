class RenameCuttlefishApp < ActiveRecord::Migration
  def change
    App.default.update_attributes(name: "Default", url: nil)
  end
end
