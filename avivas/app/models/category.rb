class Category < ApplicationRecord
    has_and_belongs_to_many :products

    validates :name, presence: true, uniqueness: true, length: { maximum: 50, message: "El nombre puede tener 50 caracteres máximo"}
end
