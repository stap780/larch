class AddColumnInsidToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :insid, :integer
  end
end
