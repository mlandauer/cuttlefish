# frozen_string_literal: true

class AddRefererToOpenEvents < ActiveRecord::Migration
  def change
    add_column :open_events, :referer, :text
  end
end
