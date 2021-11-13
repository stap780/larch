class CreateKpProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :kp_products do |t|
      t.integer :quantity
      t.decimal :price
      t.decimal :sum
      t.references :kp, foreign_key: true
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
