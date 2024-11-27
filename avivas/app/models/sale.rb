class Sale < ApplicationRecord
    has_many :product_sales, dependent: :destroy
    has_many :products, through: :product_sales

    # asociación anidada para permitir que los productos y sus cantidades sean asignados en el formulario
    accepts_nested_attributes_for :product_sales, allow_destroy: true

    validate :check_stock_availability

    private

    def check_stock_availability
        product_sales.each do |product_sale|
            product = product_sale.product
            if product && product.stock < product_sale.quantity
              errors.add(:base, "El producto '#{product.name}' no tiene suficiente stock disponible. Stock actual: #{product.stock}, solicitado: #{product_sale.quantity}.")
            end
          end
    end
end
