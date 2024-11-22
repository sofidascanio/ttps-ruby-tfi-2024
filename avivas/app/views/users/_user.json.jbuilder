json.extract! user, :id, :username, :email, :telephone, :password_digest, :entered_at, :role, :created_at, :updated_at
json.url user_url(user, format: :json)
