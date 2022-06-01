class CreateAcmeChallenges < ActiveRecord::Migration[5.2]
  def change
    create_table :acme_challenges do |t|
      t.string :token, index: { unique: true }
      t.string :content
      t.timestamps
    end
  end
end
