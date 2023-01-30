class CreateVariants < ActiveRecord::Migration[5.2]
  def change
    create_table :variants do |t|
      t.string :sku
      t.string :title
      t.string :desc
      t.integer :product_id

      t.timestamps
    end
  end
end
