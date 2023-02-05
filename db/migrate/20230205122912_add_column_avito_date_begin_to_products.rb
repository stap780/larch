class AddColumnAvitoDateBeginToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :avito_date_begin, :date
  end
end
