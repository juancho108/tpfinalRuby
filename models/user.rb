class User < ActiveRecord::Base

  # associations
  has_secure_password
  has_many :games_as_player1, :class_name => 'Game', :foreign_key => 'player1_id'
  has_many :games_as_player2, :class_name => 'Game', :foreign_key => 'player2_id'

  #validations
  validates :name,:password, presence: true,
                             allow_blank: false,
                             format: { with: /\A\p{Alnum}+\z/,message: "only allows letters and numbers" } 
  
  validates :name, length: { minimum: 2 }, uniqueness: true
  validates :password, length: { in: 6..20 }

end
