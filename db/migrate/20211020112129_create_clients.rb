class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :middlename
      t.string :surname
      t.string :phone
      t.string :email
      t.integer :zip
      t.string :state
      t.string :city
      t.string :address

      t.timestamps
    end
  end
end
