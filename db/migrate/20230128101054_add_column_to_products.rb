class AddColumnToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :offer_id, :string
    add_column :products, :barcode, :string
    add_column :products, :avito_param, :string
  end
end
