class Sale < ApplicationRecord
    has_many :product_sales, dependent: :destroy
    has_many :products, through: :product_sales

    accepts_nested_attributes_for :product_sales, allow_destroy: true

    belongs_to :user
end
