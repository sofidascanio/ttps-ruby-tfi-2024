json.extract! sale, :id, :sale_date, :sale_price, :client, :created_at, :updated_at
json.url sale_url(sale, format: :json)
