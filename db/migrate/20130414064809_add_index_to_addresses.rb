# frozen_string_literal: true

class AddIndexToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_index :addresses, :text
  end
end
