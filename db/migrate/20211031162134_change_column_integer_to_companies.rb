class ChangeColumnIntegerToCompanies < ActiveRecord::Migration[5.2]
  def change
    change_column :companies, :inn, :integer, limit: 8
    change_column :companies, :kpp, :integer, limit: 8
    change_column :companies, :ogrn, :integer, limit: 8
    change_column :companies, :okpo, :integer, limit: 8
    change_column :companies, :bik, :integer, limit: 8
  end
end
