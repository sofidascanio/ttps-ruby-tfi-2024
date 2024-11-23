class User < ApplicationRecord
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

    validates :username, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true
    validates :telephone, presence: true
    validates :role, presence: true

    enum :role, { admin: 0, manager: 1, employee: 2 }

end
