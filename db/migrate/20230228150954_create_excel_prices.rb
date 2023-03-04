class CreateExcelPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :excel_prices do |t|
      t.string :title
      t.string :link
      t.string :price_move
      t.integer :price_shift
      t.string :price_points
      t.text :comment
      t.string :file_status

      t.timestamps
    end
  end
end
