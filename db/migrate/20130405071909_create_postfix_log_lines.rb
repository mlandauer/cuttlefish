class CreatePostfixLogLines < ActiveRecord::Migration
  def change
    create_table :postfix_log_lines do |t|
      t.string :text
      t.references :email

      t.timestamps
    end
  end
end
