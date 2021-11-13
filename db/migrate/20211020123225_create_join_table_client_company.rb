class CreateJoinTableClientCompany < ActiveRecord::Migration[5.2]
  def change
    create_join_table :clients, :companies do |t|
      t.index [:client_id, :company_id]
      t.index [:company_id, :client_id]
    end
  end
end
