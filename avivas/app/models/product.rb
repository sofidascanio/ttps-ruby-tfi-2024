class Product < ApplicationRecord
    # formato hexadecimal
    validates :color, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "debe ser un código hexadecimal válido" }

    has_many_attached :images

    has_and_belongs_to_many :categories

    has_many :product_sales
    has_many :sales, through: :product_sales

    def color_object
        # convierte el código hexadecimal a un objeto RGB
        Color::RGB.from_hex(self.color)
    end

    def has_sufficient_stock?(quantity)
        stock >= quantity
    end
end
