json.extract! kp_product, :id, :quantity, :price, :sum, :kp_id, :product_id, :created_at, :updated_at
json.url kp_product_url(kp_product, format: :json)
