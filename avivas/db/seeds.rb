# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Faker::Config.locale = :es

User.create!(
    username: "sofiad",
    email: "sofia@gmail.com",
    password: "123456",
    telephone: "1234567",
    role: 0,
    entered_at: Date.strptime('20/10/2021', '%d/%m/%Y')
)

15.times do
    begin
        User.create!(
            username: Faker::Internet.unique.username(specifier: 5..12),
            email: Faker::Internet.unique.email,
            telephone: rand(10**6..10**14).to_s, 
            password: Faker::Internet.password(min_length: 6),
            role: rand(0..2),
            entered_at: Faker::Date.backward(days: 365 * 5)
        )
    rescue ActiveRecord::RecordInvalid => e
        puts "Error al crear usuario: #{e.message}"
    end
end

sizes = ["Pequeño", "Mediano", "Grande", "Extra Grande", nil]

25.times do
    Product.create!(
        name: "#{Faker::Commerce.material} #{Faker::Commerce.product_name}",
        description: Faker::Lorem.sentence(word_count: 15),
        price: Faker::Commerce.price(range: 1.0..1000.0, as_string: false),
        stock: rand(0..100),
        color: Faker::Color.color_name,
        size: sizes.sample
    )
end

50.times do
    employee = User.order('RANDOM()').first

    sale = Sale.create!(
        client: Faker::Name.name,
        user: employee
    )

    products = Product.order('RANDOM()').limit(rand(1..5))

    total_price = 0
    products.each do |product|
        ProductSale.create!(
            sale: sale,
            product: product,
            price: product.price,
            quantity: rand(1..15) 
        )
        total_price = total_price + product.price
    end

    sale.sale_price = total_price
end

15.times do
    category = Category.create!(
        name: Faker::Commerce.department(max: 1, fixed_amount: true) 
    )

    products = Product.order('RANDOM()').limit(5)

    category.products << products
end