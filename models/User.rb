class User < ActiveRecord::Base
  has_many :posts
  has_many :comments

  before_save :hash_password
  
  validates :name, presence: true, length: { minimum: 2 }
  validates :password, length: { minimum: 3 }, confirmation: true
  validates :password_confirmation, presence: true
  validates :email,
    presence: true,
    uniqueness: true,
    format: { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }

  private

  def hash_password
    self.password = Digest::MD5.hexdigest(self.password)
  end
end