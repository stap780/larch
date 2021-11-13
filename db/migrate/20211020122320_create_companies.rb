class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.boolean :our_company
      t.string :title
      t.string :fulltitle
      t.string :uraddress
      t.string :factaddress
      t.integer :inn
      t.integer :kpp
      t.integer :ogrn
      t.integer :okpo
      t.integer :bik
      t.string :banktitle
      t.string :bankaccount

      t.timestamps
    end
  end
end
