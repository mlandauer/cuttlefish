class AddDisableCssInliningToEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :emails, :disable_css_inlining, :boolean, null: false, default: false
  end
end
