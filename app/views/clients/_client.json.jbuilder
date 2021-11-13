json.extract! client, :id, :name, :middlename, :surname, :phone, :email, :zip, :state, :city, :address, :created_at, :updated_at
json.url client_url(client, format: :json)
