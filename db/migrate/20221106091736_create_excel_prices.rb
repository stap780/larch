class CreateExcelPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :excel_prices do |t|
      t.string :title
      t.integer :link
      t.string :price_move
      t.integer :price_shift
      t.string :price_points
      t.text :comment

      t.timestamps
    end
  end
end
