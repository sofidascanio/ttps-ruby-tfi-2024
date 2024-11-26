class Product < ApplicationRecord
    # formato hexadecimal
    validates :color, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "debe ser un código hexadecimal válido" }

    has_many_attached :images

    def color_object
        # convierte el código hexadecimal a un objeto RGB
        Color::RGB.from_hex(self.color)
    end
end
