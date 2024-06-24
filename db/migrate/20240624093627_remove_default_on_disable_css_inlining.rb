class RemoveDefaultOnDisableCssInlining < ActiveRecord::Migration[6.1]
  def change
    change_column_default :emails, :disable_css_inlining, from: false, to: nil
  end
end
