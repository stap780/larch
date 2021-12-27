class AddColumnCommentToKps < ActiveRecord::Migration[5.2]
  def change
    add_column :kps, :comment, :string
  end
end
