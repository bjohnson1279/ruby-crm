# app/models/user.rb
class User < ApplicationRecord
  belongs_to :firm

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
