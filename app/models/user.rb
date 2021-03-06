class User < ApplicationRecord
  attr_accessor :remember_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  before_save{email.downcase!}
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  validates :name, presence: true,
                  length: {maximum: Settings.length.name}
  validates :email, presence: true,
                    length: {maximum: Settings.length.email},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  validates :password, presence: true,
                      length: {minimum: Settings.length.password}

  has_secure_password

  def remember
    self.remember_token = User.new_token
    update_column :remember_token, User.digest(remember_token)
  end

  def authenticated? remember_token
    Bcrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_column :remember_digest, nil
  end

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end
end
