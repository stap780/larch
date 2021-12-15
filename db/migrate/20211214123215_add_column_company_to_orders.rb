class AddColumnCompanyToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :companykp1_id, :integer
    add_column :orders, :companykp2_id, :integer
    add_column :orders, :companykp3_id, :integer
  end
end
