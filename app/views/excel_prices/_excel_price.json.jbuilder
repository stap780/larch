json.extract! excel_price, :id, :title, :link, :price_move, :price_shift, :price_points, :comment, :created_at, :updated_at
json.url excel_price_url(excel_price, format: :json)
