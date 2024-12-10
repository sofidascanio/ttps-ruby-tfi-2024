class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sales

  validates :username, presence: true, uniqueness: true, length: { minimum: 5, maximum: 25, message: "puede tener 25 caracteres maximo" }
  validates :telephone, presence: true, format: { with: /\A\d{7,15}\z/, message: "debe ser un numero entre 7 y 15 digitos" }

  # 0: admin, 1: manager, 2: employee
  enum :role, [:admin, :manager, :employee], default: :employee

end
