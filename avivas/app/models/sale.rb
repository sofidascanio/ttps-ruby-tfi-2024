class Sale < ApplicationRecord
    has_many :product_sales, dependent: :destroy
    has_many :products, through: :product_sales

    # asociación anidada para permitir que los productos y sus cantidades sean asignados en el formulario
    accepts_nested_attributes_for :product_sales, allow_destroy: true
end
