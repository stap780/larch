class AddColumnDescToKpProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :kp_products, :desc, :string
  end
end
