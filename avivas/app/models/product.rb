class Product < ApplicationRecord
    has_many_attached :images

    validates :name, presence: true, length: { maximum: 100, message: "puede tener 100 caracteres máximo"}
    validates :description, length: { maximum: 255, message: "puede tener 255 caracteres máximo"}, allow_blank: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, message: "debe ser mayor a 0" }
    validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0, message: "debe ser igual o mayor a 0" }
    validates :size, length: { maximum: 20 }, allow_blank: true

    has_and_belongs_to_many :categories

    has_many :product_sales
    has_many :sales, through: :product_sales

    def color_object
        Color::RGB.from_hex(self.color)
    end

    def self.ransackable_attributes(auth_object = nil)
        ["name", "description"]  
    end
end