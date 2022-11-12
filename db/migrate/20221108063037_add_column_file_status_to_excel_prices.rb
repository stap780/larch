class AddColumnFileStatusToExcelPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :excel_prices, :file_status, :boolean
  end
end
