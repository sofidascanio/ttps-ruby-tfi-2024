class Sale < ApplicationRecord
    has_many :product_sales, dependent: :destroy
    has_many :products, through: :product_sales

    accepts_nested_attributes_for :product_sales, allow_destroy: true

    belongs_to :user

    before_save :total_price

    validates :client, presence: true, length: { maximum: 200, message: "puede tener 200 caracteres maximo" }
    validates :sale_price, numericality: { greater_than: 0, message: "debe ser mayor a 0" }

    private

    def total_price
        self.sale_price = self.product_sales.sum { |p| p.quantity * p.price }
    end
end
