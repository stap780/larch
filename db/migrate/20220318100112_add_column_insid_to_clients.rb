class AddColumnInsidToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :insid, :integer
  end
end
