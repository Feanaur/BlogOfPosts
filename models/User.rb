class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  #добавить валидацию 
  #И хэширование полученного пароля
  def self.save
    
  end
end