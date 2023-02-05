class AddColumnPeriodToVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :variants, :period, :integer
  end
end
