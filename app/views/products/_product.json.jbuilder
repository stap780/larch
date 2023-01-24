json.extract! product, :id, :sku, :title, :desc, :quantity, :costprice, :price, :created_at, :updated_at
json.url product_url(product, format: :json)
