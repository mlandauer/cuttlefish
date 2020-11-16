# frozen_string_literal: true

class AddUrlIndexToLinks < ActiveRecord::Migration[4.2]
  def change
    add_index :links, :url
  end
end
