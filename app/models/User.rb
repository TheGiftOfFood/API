require 'data_mapper'
require 'bcrypt'

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial
  property :email, String
  property :password, BCryptHash
  property :token, String

  validates_presence_of :email
  validates_presence_of :password

  def password=(new_password)
    self.attribute_set(:password, BCrypt::Password.create(new_password))
  end

  def generate_token!
    t = Time.now.to_i + (60 * 60)
    self.attribute_set(:token, SecureRandom.urlsafe_base64(64)+'.'+t.hash.to_s)
    self.save!
  end
end
