class AddColumnSkuToKpProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :kp_products, :sku, :string
  end
end
