class AddColumnInsidToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :insid, :integer
  end
end
