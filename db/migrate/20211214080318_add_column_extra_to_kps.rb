class AddColumnExtraToKps < ActiveRecord::Migration[5.2]
  def change
    add_column :kps, :extra, :integer
  end
end
