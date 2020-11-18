# frozen_string_literal: true

class AddFromDomainToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :from_domain, :string
  end
end
