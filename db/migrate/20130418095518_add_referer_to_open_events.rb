# frozen_string_literal: true

class AddRefererToOpenEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :open_events, :referer, :text
  end
end
