# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Para borrar las imagenes que habian quedado de productos.
storage_path = Rails.root.join('storage', 'product_images')

if Dir.exist?(storage_path)
  FileUtils.rm_rf(storage_path)

  puts "Se borraron las imagenes de productos"
else
  puts "El directorio storage/product_images no existe o esta vacío."
end

Faker::Config.locale = :es

User.create!(
    username: "sofiad",
    email: "sofia@gmail.com",
    password: "123456",
    telephone: "1234567",
    role: 0,
    entered_at: Date.strptime('20/10/2021', '%d/%m/%Y')
)

User.create!(
    username: "jorgegomez",
    email: "jorge@gmail.com",
    password: "123456",
    telephone: "1234567",
    role: 0,
    entered_at: Date.strptime('14/07/2024', '%d/%m/%Y')
)

User.create!(
    username: "juanperez",
    email: "juan@gmail.com",
    password: "123456",
    telephone: "1234567",
    role: 1,
    entered_at: Date.strptime('15/07/2020', '%d/%m/%Y')
)

User.create!(
    username: "luciaro",
    email: "lucia@gmail.com",
    password: "123456",
    telephone: "1234567",
    role: 1,
    entered_at: Date.strptime('19/03/2023', '%d/%m/%Y')
)

User.create!(
    username: "pedrolopez",
    email: "pedro@gmail.com",
    password: "123456",
    telephone: "1234567",
    role: 2,
    entered_at: Date.strptime('04/03/2023', '%d/%m/%Y')
)

User.create!(
    username: "martinap",
    email: "martina@gmail.com",
    password: "123456",
    telephone: "1234567",
    role: 2,
    entered_at: Date.strptime('10/10/2022', '%d/%m/%Y')
)

15.times do
    User.create!(
        username: Faker::Internet.unique.username(specifier: 5..15),
        email: Faker::Internet.unique.email,
        telephone: rand(10**6..10**14).to_s,
        password: Faker::Internet.password(min_length: 6),
        role: rand(0..2),
        entered_at: Faker::Date.backward(days: 365 * 5)
    )
end

sizes = [ "Pequeño", "Mediano", "Grande", "Extra Grande", "32", "34", "36", "38", "40", nil ]

100.times do
    product = Product.create!(
        name: "#{Faker::Commerce.material} #{Faker::Commerce.product_name}",
        description: Faker::Lorem.sentence(word_count: 15),
        price: Faker::Commerce.price(range: 1.0..1000.0, as_string: false),
        stock: rand(0..100),
        color: Faker::Color.color_name,
        size: sizes.sample
    )

    # Cargo imagenes para los productos
    image_files = Dir[Rails.root.join('app', 'assets', 'images', 'products', '*.{jpg,png,gif,jpeg, webp}')]

    selected_images = image_files.sample(3)

    selected_images.each do |image_path|
        product.images.attach(io: File.open(image_path), filename: File.basename(image_path))
    end
end

50.times do
    employee = User.order('RANDOM()').first

    sale = Sale.create!(
        client: Faker::Name.name,
        user: employee
    )

    products = Product.order('RANDOM()').limit(rand(1..5))

    products.each do |product|
        product_sale = ProductSale.create!(
            sale: sale,
            product: product,
            price: product.price,
            quantity: rand(1..15)
        )
    end

    # para que vuelva a cargar la relacion y el sale.save para que ejecute el callback del calculo
    sale.product_sales.reload
    sale.save
end

15.times do
    category_name = Faker::Commerce.department(max: 1, fixed_amount: true)
    while Category.exists?(name: category_name)
        category_name = Faker::Commerce.department(max: 1, fixed_amount: true)
    end

    category = Category.create!(name: category_name)

    products = Product.order('RANDOM()').limit(20)

    category.products << products
end
