class ChangeColumnTypeToExcelPrices < ActiveRecord::Migration[5.2]
  def change
    change_column :excel_prices, :link, :string
  end
end
