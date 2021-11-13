class CreateKps < ActiveRecord::Migration[5.2]
  def change
    create_table :kps do |t|
      t.string :vid
      t.string :status
      t.string :title
      t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
