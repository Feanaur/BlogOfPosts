require "digest/md5"

class User < ActiveRecord::Base
  has_many :posts
  has_many :comments

  before_save :hash_password
  
  validates :name, presence: true, length: { minimum: 2 }
  validates :password, length: { minimum: 8 }, confirmation: true
  validates :password_confirmation, presence: true
  validates :email,
    presence: true,
    uniqueness: true,
    format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }
  
  def auth(pass_string)
    self.password==str_hash(pass_string)
  end

  private

  def hash_password
    self.password = str_hash(self.password)
  end

  def str_hash(str)
    Digest::MD5.hexdigest(str)
  end

end