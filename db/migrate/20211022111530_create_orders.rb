class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :status
      t.integer :number
      t.integer :client_id

      t.timestamps
    end
  end
end
