class Sale < ApplicationRecord
    has_many :product_sales, dependent: :destroy
    has_many :products, through: :product_sales

    # asociación anidada para permitir que los productos y sus cantidades sean asignados en el formulario
    accepts_nested_attributes_for :product_sales, allow_destroy: true

    belongs_to :user

    before_save :calculate_sale_price

    private

    def calculate_sale_price
        self.sale_price = product_sales.sum { |ps| ps.quantity * ps.price }
    end
end
