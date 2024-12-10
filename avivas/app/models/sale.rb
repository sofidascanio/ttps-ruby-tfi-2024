class Sale < ApplicationRecord
    has_many :product_sales, dependent: :destroy
    has_many :products, through: :product_sales

    accepts_nested_attributes_for :product_sales, allow_destroy: true

    belongs_to :user

    # lo uso solo en el update, si uso before_save el seeds no calcula el precio
    before_update :total_price

    validates :client, presence: true, length: { maximum: 200, message: "puede tener 200 caracteres maximo" }

    private

    def total_price
        self.sale_price = self.product_sales.sum { |p| p.quantity * p.price }
    end
end
