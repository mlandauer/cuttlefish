# frozen_string_literal: true

class AddIndexToAddresses < ActiveRecord::Migration
  def change
    add_index :addresses, :text
  end
end
