# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

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
        username: Faker::Internet.unique.username(specifier: 5..12), # Entre 5 y 12 caracteres
        email: Faker::Internet.unique.email,
        telephone: Faker::Number.leading_zero_number(digits: rand(7..15)),
        password: Faker::Internet.password(min_length: 6),
        role: rand(0..2), # Valores posibles: 0, 1, o 2
        entered_at: Faker::Date.backward(days: 365 * 5) # Fecha aleatoria en los últimos 5 años
      )
    rescue ActiveRecord::RecordInvalid => e
      puts "Error al crear usuario: #{e.message}"
    end
end

25.times do
    Product.create!(
      name: Faker::Commerce.unique.product_name,  # Nombre de producto único
      description: Faker::Lorem.sentence(word_count: 15), # Oración de 15 palabras
      price: Faker::Commerce.price(range: 1.0..1000.0, as_string: false), # Precio entre 1.0 y 1000.0
      stock: rand(0..100), # Stock entre 0 y 100
      color: Faker::Color.hex_color # Color en formato hexadecimal
    )
end
  

50.times do
    # Selecciona un usuario (empleado) aleatorio
    employee = User.order('RANDOM()').first

    # Crea la venta
    sale = Sale.create!(
        client: Faker::Name.name, # Nombre del cliente
        user: employee            # Relación con el usuario (empleado)
    )

    # Selecciona entre 1 y 5 productos aleatorios
    products = Product.order('RANDOM()').limit(rand(1..5))

    # Relaciona los productos con la venta
    products.each do |product|
        ProductSale.create!(
        sale: sale,
        product: product
        )
    end
end

15.times do
    # Crear una categoría
    category = Category.create!(
      name: Faker::Commerce.department(max: 1, fixed_amount: true) # Nombre único para la categoría
    )
  
    # Seleccionar productos aleatorios para asociar con la categoría
    products = Product.order('RANDOM()').limit(5)
  
    # Relacionar la categoría con los productos
    category.products << products
end