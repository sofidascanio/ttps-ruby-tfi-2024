class ProductSale < ApplicationRecord
  belongs_to :product
  belongs_to :sale

  before_destroy :return_stock

  private

  def return_stock
    product.stock += self.quantity
    product.save!
  end
end
