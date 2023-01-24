class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :sku
      t.string :title
      t.string :desc
      t.integer :quantity
      t.decimal :costprice
      t.decimal :price

      t.timestamps
    end
  end
end
