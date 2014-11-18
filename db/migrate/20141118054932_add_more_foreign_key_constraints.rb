class AddMoreForeignKeyConstraints < ActiveRecord::Migration
  def change
    add_foreign_key(:emails, :addresses, column: 'from_address_id')
    add_foreign_key(:deliveries, :addresses)
    add_foreign_key(:black_lists, :addresses)
    add_foreign_key(:black_lists, :deliveries, column: 'caused_by_delivery_id')
    add_foreign_key(:delivery_links, :links)
  end
end
