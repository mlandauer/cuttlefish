class RenameCuttlefishApp < ActiveRecord::Migration
  def change
    App.cuttlefish.update_attributes(name: "Default", url: nil)
  end
end
