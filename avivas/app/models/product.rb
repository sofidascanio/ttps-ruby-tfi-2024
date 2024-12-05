class Product < ApplicationRecord
    has_many_attached :images

    validates :size, length: { maximum: 20 }, allow_blank: true

    has_and_belongs_to_many :categories

    has_many :product_sales
    has_many :sales, through: :product_sales

    def color_object
        # chequear si es necesario
        # convierte el código hexadecimal a un objeto RGB
        Color::RGB.from_hex(self.color)
    end

    def self.ransackable_attributes(auth_object = nil)
        ["name", "description"]  
    end
end