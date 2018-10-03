# frozen_string_literal: true

class AddUrlIndexToLinks < ActiveRecord::Migration
  def change
    add_index :links, :url
  end
end
