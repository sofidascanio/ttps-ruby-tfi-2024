class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :telephone, presence: true, format: { with: /\A\d{7,15}\z/, message: "solo números, entre 7 y 15 dígitos" }

  # 0: admin, 1: manager, 2: employee
  enum :role, [:admin, :manager, :employee], default: :employee

end
