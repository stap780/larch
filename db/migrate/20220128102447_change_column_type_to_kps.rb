class ChangeColumnTypeToKps < ActiveRecord::Migration[5.2]
  def change
    change_column :kps, :extra, :decimal,  :precision => 8, :scale => 2
  end
end
