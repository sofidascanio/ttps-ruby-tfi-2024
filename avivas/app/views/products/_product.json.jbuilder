json.extract! product, :id, :name, :description, :price, :stock, :color, :deleted_at, :created_at, :updated_at
json.url product_url(product, format: :json)
