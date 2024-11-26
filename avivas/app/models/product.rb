class Product < ApplicationRecord
    # Valida que el color esté en formato hexadecimal
    validates :color, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "debe ser un código hexadecimal válido" }

    # Método para obtener un objeto de color a partir del código hexadecimal almacenado
    def color_object
        Color::RGB.from_hex(self.color) # Convierte el código hexadecimal a un objeto RGB
    end
end
