# frozen_string_literal: true

class AddFromDomainToApps < ActiveRecord::Migration
  def change
    add_column :apps, :from_domain, :string
  end
end
